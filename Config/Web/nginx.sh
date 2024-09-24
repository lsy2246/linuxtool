#!/bin/bash

if ! command -v nginx &> /dev/null; then
    if [[ -f "/usr/bin/apt-get" ]];then
      apt-get update -y
      apt-get install nginx -y
    elif [[ -f "/usr/bin/apt" ]];then
      apt update -y
      apt install nginx -y
    elif [[ -f "/usr/bin/pacman" ]];then
      pacman -Syu --noconfirm
      pacman -Sy --noconfirm nginx
    else
      echo "nginx未安装"
      exit
    fi
fi

declare pick
echo "========$(basename $0 .sh)========"
echo "1.新增站点配置文件"
echo "2.查看已有站点配置文件"
echo "3.删除站点配置文件"
read -p "请选择：" pick
case $pick in
'1')
  declare domain
  read -p "请输入要绑定的域名多个用 空格 隔开：" domain

  declare ssl_certificate
  declare ssl_certificate_key
  declare ssl_domain=$(echo "${domain}" | awk '{print $1}')

  echo "ssl证书地址"
  echo "证书,默认 ${HOME}/.acme.sh/${ssl_domain}_ecc/fullchain.cer"
  read -p "请输入证书地址：" ssl_certificate
  if [[ -z $ssl_certificate ]];then
    ssl_certificate="${HOME}/.acme.sh/${ssl_domain}_ecc/fullchain.cer"
  fi
  echo "密钥,默认 ${HOME}/.acme.sh/${ssl_domain}_ecc/${ssl_domain}.key"

  read -p "请输入密钥地址：" ssl_certificate_key
  if [[ -z $ssl_certificate_key ]];then
    ssl_certificate_key="${HOME}/.acme.sh/${ssl_domain}_ecc/${ssl_domain}.key"
  fi
  declare name
  read -p "请输入配置文件名,默认为域名：" name
  if [[ -z $name ]]; then
      name=$ssl_domain
  fi

  echo "工作方式"
  echo "1.反向代理（默认）"
  echo "2.静态文件"
  read -p "请选择：" pick
  declare path
  declare mode_pick
  if [[ $pick == 2 ]]; then
    read -p "请输入要代理的站点路径" path
    cat > "/etc/nginx/sites-available/${name}.conf" << EOF
server {
    listen 443 ssl;  # 监听 443 端口并启用 SSL
    server_name ${domain};  # 替换为你的域名

    # SSL 证书配置
    ssl_certificate ${ssl_certificate};  # 证书文件路径
    ssl_certificate_key ${ssl_certificate_key};  # 证书密钥文件路径
    ssl_protocols TLSv1.2 TLSv1.3;  # 仅使用安全的 TLS 协议版本
    ssl_ciphers HIGH:!aNULL:!MD5;  # 安全的密码套件
    ssl_prefer_server_ciphers on;  # 优先使用服务器的密码套件
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # HTTP/2 支持（可选）
    listen 443 ssl http2;

    # HSTS（HTTP 严格传输安全）强制浏览器使用 HTTPS
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # 静态文件目录
    root ${path};
    index index.html index.htm;

    # 日志
    access_log /var/log/nginx/example.com_access.log;
    error_log /var/log/nginx/example.com_error.log;

    # 默认处理
    location / {
        try_files \$uri \$uri/ =404;
    }

    # 防止访问隐藏文件（如 .git）
    location ~ /\. {
        deny all;
    }

    # 错误页面配置
    error_page 404 /404.html;
    location = /404.html {
        root /var/www/example.com/html;
    }
}

# HTTP 到 HTTPS 重定向
server {
    listen 80;  # 监听 80 端口
    server_name ${domain};

    # 将所有 HTTP 请求重定向到 HTTPS
    return 301 https://\$host\$request_uri;
}
EOF
  else
    read -p "请输入后端服务器的地址,如果只输入数字代表端口：" path
    if [[ $path =~ [0-9]+ ]]; then
        path="http://127.0.0.1:${path}"
    fi
    cat > "/etc/nginx/sites-available/${name}.conf" << EOF
server {
    listen 443 ssl http2;  # 监听 443 端口，并启用 HTTP/2
    server_name ${domain};  # 替换为你的域名

    # SSL 证书配置
    ssl_certificate ${ssl_certificate};  # 证书文件路径
    ssl_certificate_key ${ssl_certificate_key};  # 证书密钥文件路径
    ssl_protocols TLSv1.2 TLSv1.3;  # 使用安全的 TLS 协议版本
    ssl_ciphers HIGH:!aNULL:!MD5;  # 安全密码套件
    ssl_prefer_server_ciphers on;

    # 启用 SSL session 缓存和超时设置
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # 强制使用 HTTPS (HSTS)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # 日志设置
    access_log /var/log/nginx/${name}_access.log;
    error_log /var/log/nginx/${name}_error.log;

    # 反向代理到后台应用
    location / {
        proxy_pass ${path};  # 反向代理到后端应用服务器
        proxy_set_header Host \$host;  # 保持原始主机头
        proxy_set_header X-Real-IP \$remote_addr;  # 传递客户端的真实 IP
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;  # 传递代理链中的 IP
        proxy_set_header X-Forwarded-Proto \$scheme;  # 传递协议（HTTP 或 HTTPS）

        # 防止后端服务器返回不安全的内容
        proxy_redirect off;

        # 超时时间配置
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        send_timeout 60s;
    }

    # 错误页面配置
    error_page 502 /502.html;
    location = /502.html {
        root /usr/share/nginx/html;  # 错误页面路径
    }
}

# HTTP 到 HTTPS 重定向
server {
    listen 80;  # 监听 HTTP 80 端口
    server_name ${domain};  # 替换为你的域名

    # 将所有 HTTP 请求重定向到 HTTPS
    return 301 https://\$host\$request_uri;
}
EOF
  fi
  ln -s "/etc/nginx/sites-available/${name}.conf" "/etc/nginx/sites-enabled"
  nginx -s reload &> /dev/null
  echo "配置完成"
  ;;
esac