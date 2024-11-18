#!/bin/bash
declare selected_mode=$1
declare domain_names=$2

if ! [[ $selected_mode == "nginx" ]]; then
    selected_mode=""
    domain_names=""
fi

declare domain_string

if [[ ! $domain_names ]];then
  echo "请输入需要申请SSL证书的域名"
  read -p "请输入要绑定的域名（多个用空格隔开）：" domain_names
fi

for i in ${domain_names} ; do
    if [[ ! $i =~ [\w+\.]+ ]];then
      echo "域名不合法"
      exit
    else
      domain_string="$domain_string -d $i"
    fi
done

if [[ -z $domain_string ]]; then
    echo "需要添加的域名不能为空"
    exit
fi

echo "1.http验证"
echo "2.dns验证"
read -p "请选择验证模式：" selected_mode

case $selected_mode in
'1')
    declare mode
    if command -v nginx &> /dev/null; then
      mode="nginx"
      cat > "/etc/nginx/conf.d/test.conf" << EOF
server {
    listen       80;                  # 监听80端口
    server_name  ${domain_names};           # 服务器名称（本地）

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
    eval "${HOME}/.acme.sh/acme.sh --issue ${domain_string} --${mode}"
    rm /etc/nginx/conf.d/test.conf
  ;;
'2')
  declare pick=0
  declare -a mode_array
  mode_array[1]="TXT记录"
  mode_array[2]='cloudflare'
  for i in "${!mode_array[@]}"; do
      ((pick++))
      echo "${pick}. ${mode_array[$i]}"
  done
  read -p "请选择验证模式：" selected_mode
  if [[ ! $selected_mode =~ [1-${pick}] ]]; then
      exit
  fi

  case ${mode_array[$selected_mode]} in
  'TXT记录')
      declare log_output=$(${HOME}/.apple.sh/apple.sh --issue --dns $domain_string --yes-I-know-dns-manual-mode-enough-go-ahead-please)
      declare -a domain=($( echo "$log_output" | grep "Domain:" | awk -F ": " '{print $2}'))
      declare -a txt_value=($(echo "$log_output" | grep "TXT value:" | awk -F ": " '{print $2}'))
      echo "请到dns系统解析TXT记录"
      for (( i = 0; i < ${#domain[@]}; i++ )); do
          echo "需要解析的第$((i+1))条"
          echo "名称: ${domain[$i]}"
          echo "文本记录：${txt_value[$i]}"
      done

      read -p "解析完成请输入 y：" selected_mode
      if [[ $selected_mode =~ [Yy] ]]; then
          eval "${HOME}/.acme.sh/acme.sh --renew $domain_string --yes-I-know-dns-manual-mode-enough-go-ahead-please"
      else
        echo "解析完成后请输入下面的命令完成验证"
        echo "${HOME}/.acme.sh/acme.sh --renew $domain_string --yes-I-know-dns-manual-mode-enough-go-ahead-please"
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
      eval "${HOME}/.acme.sh/acme.sh --issue $domain_string --dns dns_cf"
  esac
  ;;
esac




