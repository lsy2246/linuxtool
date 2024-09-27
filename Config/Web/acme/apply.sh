#!/bin/bash
declare pick_mode=$1
declare domain=$2

if ! [[ $pick_mode == "nginx" ]]; then
    pick_mode=""
    domain=""
fi

declare domain_str

if [[ ! $domain ]];then
  echo "请输入需要申请SSL证书的域名"
  read -p "请输入要绑定的域名多个用 空格 隔开：" domain
fi


for i in ${domain} ; do
    if [[ ! $i =~ [\w+\.]+ ]];then
      echo "域名不合法"
      exit
    else
      domain_str="$domain_str -d $i"
    fi
done

if [[ -z $domain_str ]]; then
    echo "需要添加的域名不能为空"
    exit
fi

echo "1.http验证"
echo "2.dns验证"
read -p "请选择验证模式：" pick_mode

case $pick_mode in
'1')
    declare mode
    if command -v nginx &> /dev/null; then
      mode="nginx"
      cat > "/etc/nginx/conf.d/test.conf" << EOF
server {
    listen       80;                  # 监听80端口
    server_name  ${domain};           # 服务器名称（本地）

    location / {
        root   /usr/share/nginx/html; # 指定根目录
        index  index.html index.htm;  # 默认页面
    }
}
EOF
    elif command -v apache &> /dev/null; then
      mode="apache"
    else
      mode="standalone"
    fi
    echo "请到服务器将80和443端口开启,将域名解析到本机"
    read -p "解析完成请回车："
    eval "${HOME}/.acme.sh/acme.sh --issue ${domain_str} --${mode}"
    rm /etc/nginx/conf.d/test.conf
  ;;
'2')
  declare pick=0
  declare -a mode_arr
  mode_arr[1]="TXT记录"
  mode_arr[2]='cloudflare'
  for i in "${!mode_arr[@]}"; do
      ((pick++))
      echo "${pick}. ${mode_arr[$i]}"
  done
  read -p "请选择验证模式：" pick_mode
  if [[ ! $pick_mode =~ [1-${pick}] ]]; then
      exit
  fi

  case ${mode_arr[$pick_mode]} in
  'TXT记录')
      declare log_output=$(${HOME}/.apple.sh/apple.sh --issue --dns $domain_str --yes-I-know-dns-manual-mode-enough-go-ahead-please)
      declare -a domain=($( echo "$log_output" | grep "Domain:" | awk -F ": " '{print $2}'))
      declare -a txt_value=($(echo "$log_output" | grep "TXT value:" | awk -F ": " '{print $2}'))
      echo "请到dns系统解析TXT记录"
      for (( i = 0; i < ${#domain[@]}; i++ )); do
          echo "需要解析的第$((i+1))条"
          echo "名称: ${domain[$i]}"
          echo "文本记录：${txt_value[$i]}"
      done

      read -p "解析完成请输入 y：" pick
      if [[ $pick =~ [Yy] ]]; then
          eval "${HOME}/.acme.sh/acme.sh --renew $domain_str --yes-I-know-dns-manual-mode-enough-go-ahead-please"
      else
        echo "解析完成后请输入下面的命令完成验证"
        echo "${HOME}/.acme.sh/acme.sh --renew $domain_str --yes-I-know-dns-manual-mode-enough-go-ahead-please"
      fi
    ;;
  'cloudflare')
      declare CF_Key
      declare CF_Email
      read -p "请输入cloudflare的邮箱：" CF_Email
      if [[ ! $CF_Email =~ .*@.* ]];then
            echo "邮箱不合法"
            exit
      fi
      read -p "请输入cloudflare的密钥：" CF_Key
      export CF_Key=$CF_Key
      export CF_Email=$CF_Email
      eval "${HOME}/.acme.sh/acme.sh --issue $domain_str --dns dns_cf"
  esac
  ;;
esac




