declare domain_names
read -p "请输入要绑定的域名（多个用空格隔开）：" domain_names

declare ssl_cert_path
declare ssl_key_path
declare primary_domain=$(echo "${domain_names}" | awk '{print $1}')
declare folder_domain
echo "SSL证书选择"
echo "1.自动申请（默认）"
echo "2.手动输入"
read -p "请输入选择：" user_choice
if [[ $user_choice == 2 ]]; then

  folder_domain=$(ls ${HOME}/.acme.sh/ | grep "^${primary_domain}" | head -n1)
  echo "证书路径, 默认 ${HOME}/.acme.sh/${folder_domain:-"${primary_domain}_ecc"}/fullchain.cer"
  read -p "请输入证书地址：" ssl_cert_path
  if [[ -z $ssl_cert_path ]]; then
    ssl_cert_path="${HOME}/.acme.sh/${folder_domain:-"${primary_domain}_ecc"}/fullchain.cer"

  fi
  echo "密钥路径, 默认 ${HOME}/.acme.sh/${folder_domain:-"${primary_domain}_ecc"}/${primary_domain}.key"

  read -p "请输入密钥地址：" ssl_key_path
  if [[ -z $ssl_key_path ]]; then
    ssl_key_path="${HOME}/.acme.sh/${folder_domain:-"${primary_domain}_ecc"}/${primary_domain}.key"
  fi
else
  echo "1.nginx（默认）"
  read -p "请选择：" user_choice
  bash "$(dirname $(dirname $0))/acme/_init.sh"
  bash "$(dirname $(dirname $0))/acme/apply.sh" "nginx" "${domain_names}"
  folder_domain=$(ls ${HOME}/.acme.sh/ | grep "^${primary_domain}" | head -n1)
  ssl_cert_path="${HOME}/.acme.sh/${folder_domain}/fullchain.cer"
  ssl_key_path="${HOME}/.acme.sh/${folder_domain}/${primary_domain}.key"
fi

declare config_file_name
read -p "请输入配置文件名（默认为域名）：" config_file_name
if [[ -z $config_file_name ]]; then
  config_file_name=$primary_domain
fi

echo "工作方式选择"
echo "1.反向代理（默认）"
echo "2.静态文件"
read -p "请选择：" user_choice
declare site_path
if [[ $user_choice == 2 ]]; then
  read -p "请输入要代理的站点路径：" site_path
  cat >"/etc/nginx/sites-available/${config_file_name}.conf" <<EOF
server {
  listen 443 ssl http2;  # 监听 443 端口并启用 SSL 和 HTTP/2
  server_name ${domain_names};  # 替换为你的域名

  # SSL 证书配置
  ssl_certificate ${ssl_cert_path};  # 证书文件路径
  ssl_certificate_key ${ssl_key_path};  # 证书密钥文件路径
  ssl_protocols TLSv1.2 TLSv1.3;  # 仅使用安全的 TLS 协议版本
  ssl_ciphers HIGH:!aNULL:!MD5;  # 安全的密码套件
  ssl_prefer_server_ciphers on;  # 优先使用服务器的密码套件
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;

  # HSTS（HTTP 严格传输安全）强制浏览器使用 HTTPS
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

  # 设置文件传输的最大大小
  client_max_body_size 100M;  # 上传文件最大大小 (例如 100MB)
  proxy_max_temp_file_size 1024m;  # 代理最大临时文件大小

  # 超时与缓冲设置
  client_body_timeout 60s;  # 等待客户端发送请求主体的超时时间
  client_header_timeout 60s;  # 等待客户端发送请求头的超时时间
  send_timeout 60s;  # 发送响应的超时时间
  client_body_buffer_size 128k;  # 上传缓冲区大小
  proxy_buffer_size 4k;  # 设置代理服务器响应的缓冲区大小
  proxy_buffers 8 16k;  # 代理服务器的缓冲区数和大小
  proxy_busy_buffers_size 64k;  # 忙碌代理缓冲区大小
  large_client_header_buffers 4 16k;  # 设置较大的客户端头部缓冲区，防止上传大文件时出现 413 错误

  # 静态文件目录
  root ${site_path};
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
  server_name ${domain_names};

  # 将所有 HTTP 请求重定向到 HTTPS
  return 301 https://\$host\$request_uri;
}

EOF
else
  read -p "请输入后端服务器的地址，如果只输入数字代表端口：" site_path
  if [[ $site_path =~ [0-9]+ ]]; then
    site_path="http://127.0.0.1:${site_path}"
  fi
  cat >"/etc/nginx/sites-available/${config_file_name}.conf" <<EOF
server {
  listen 443 ssl http2;  # 监听 443 端口，并启用 HTTP/2
  server_name ${domain_names};  # 替换为你的域名

  # SSL 证书配置
  ssl_certificate ${ssl_cert_path};  # 证书文件路径
  ssl_certificate_key ${ssl_key_path};  # 证书密钥文件路径
  ssl_protocols TLSv1.2 TLSv1.3;  # 使用安全的 TLS 协议版本
  ssl_ciphers HIGH:!aNULL:!MD5;  # 安全密码套件
  ssl_prefer_server_ciphers on;

  # 启用 SSL session 缓存和超时设置
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;

  # 强制使用 HTTPS (HSTS)
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

  # 日志设置
  access_log /var/log/nginx/${config_file_name}_access.log;
  error_log /var/log/nginx/${config_file_name}_error.log;

  # 错误页面配置
  error_page 404 /404.html;
  location = /404.html {
      root /var/www/example.com/html;
  }

  # 设置文件传输的最大大小
  client_max_body_size 100M;  # 上传文件最大大小 (例如 100MB)
  proxy_max_temp_file_size 1024m;  # 代理最大临时文件大小

  # 超时与缓冲设置
  client_body_timeout 60s;  # 等待客户端发送请求主体的超时时间
  client_header_timeout 60s;  # 等待客户端发送请求头的超时时间
  send_timeout 60s;  # 发送响应的超时时间
  client_body_buffer_size 128k;  # 上传缓冲区大小
  proxy_buffer_size 4k;  # 设置代理服务器响应的缓冲区大小
  proxy_buffers 8 16k;  # 代理服务器的缓冲区数和大小
  proxy_busy_buffers_size 64k;  # 忙碌代理缓冲区大小
  large_client_header_buffers 4 16k;  # 设置较大的客户端头部缓冲区，防止上传大文件时出现 413 错误

  # 反向代理到后台应用 (常规 HTTP/HTTPS)
  location / {
      proxy_pass ${site_path};  # 反向代理到后端应用服务器
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

  # WebSocket 反向代理到后台应用
  location /ws {
      proxy_pass ${site_path};  # 反向代理到 WebSocket 应用服务器
      proxy_http_version 1.1;  # WebSocket 必须使用 HTTP 1.1
      proxy_set_header Upgrade \$http_upgrade;  # 升级请求头，用于 WebSocket
      proxy_set_header Connection "Upgrade";  # 持久连接，保持 WebSocket 连接
      proxy_set_header Host \$host;  # 保持原始主机头
      proxy_set_header X-Real-IP \$remote_addr;  # 传递客户端的真实 IP
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;  # 传递代理链中的 IP
      proxy_set_header X-Forwarded-Proto \$scheme;  # 传递协议（HTTP 或 HTTPS）

      # 超时时间配置 (WebSocket 是长连接)
      proxy_connect_timeout 60s;
      proxy_send_timeout 60s;
      proxy_read_timeout 3600s;  # WebSocket 长连接需较长读超时
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
  server_name ${domain_names};  # 替换为你的域名

  # 将所有 HTTP 请求重定向到 HTTPS
  return 301 https://\$host\$request_uri;
}

EOF
fi
ln -s "/etc/nginx/sites-available/${config_file_name}.conf" "/etc/nginx/sites-enabled" &>/dev/null
nginx -s reload &>/dev/null
echo "配置完成"
