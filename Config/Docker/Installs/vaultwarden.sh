#!/bin/bash
declare installation_directory=$1
declare web_service_port=$2

declare admin_password
read -p "请输入管理员密码（不输入则关闭管理员功能）：" admin_password

cd $installation_directory
cat > "docker-compose.yml" << EOF
version: '3.8'
services:
  bitwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    environment:
      - SIGNUPS_ALLOWED=true
      - WEBSOCKET_ENABLED=true
      - TZ=Asia/Shanghai
      - ADMIN_TOKEN="$admin_password"
    volumes:
      - ./:/data/
    ports:
      - "${web_service_port}:80"
EOF

if [[ -z $admin_password ]];then
	sed -i '/.*ADMIN_TOKEN=.*/d' "docker-compose.yml"
fi

mkdir templates
cd templates
wget https://github.com/wcjxixi/vaultwarden-lang-zhcn/archive/refs/heads/main.zip
unzip main.zip
rm main.zip
cd vaultwarden-lang-zhcn-main 
declare admin_file=$( ls | grep "admin" | tac | head -n 1 )
declare email_file=$( ls | grep "email" | tac | head -n 1 )
mv "$admin_file" "../admin"
mv "$email_file" "../email"
cd ..
rm -rf vaultwarden-lang-zhcn-main
docker compose up -d || echo "安装失败" && exit
echo "需要反向代理，使用HTTPS才能正常使用"
