#!/bin/bash
declare path=$1
declare port=$2

declare password
read -p "请输入管理员密码(不输入则关闭管理员)：" password

cd $path
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
      - ADMIN_TOKEN="$password"
    volumes:
      - ./:/data/
    ports:
      - "${port}:80"
EOF

if [[ -z $password ]];then
	sed -i '/.*ADMIN_TOKEN=.*/d' "docker-compose.yml"
fi

mkdir templates
cd templates
wget https://github.com/wcjxixi/vaultwarden-lang-zhcn/archive/refs/heads/main.zip
unzip main.zip
rm main.zip
cd vaultwarden-lang-zhcn-main 
declare admin=$( ls | grep "admin" | tac | head -n 1 )
declare email=$( ls | grep "email" | tac | head -n 1 )
mv "$admin" "../admin"
mv "$email" "../email"
cd ..
rm -rf vaultwarden-lang-zhcn-main
sudo docker compose up -d || echo "安装失败" && exit
echo "需要反向代理,使用https,才能正常使用"
