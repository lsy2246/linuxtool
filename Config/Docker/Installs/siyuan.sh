#!/bin/bash
declare installation_directory=$1
declare web_service_port=$2
declare access_password
read -p "请输入思源访问密码（默认：Siyuan）：" access_password

if [[ -z $access_password ]];then
	access_password="Siyuan"
fi

chown -R 1000:1000 $installation_directory
cd $installation_directory
cat > "docker-compose.yml" << EOF
version: "3.9"
services:
  siyuan:
    image: b3log/siyuan
    container_name: siyuan
    user: '1000:1000'
    restart: always
    ports:
      - $web_service_port:6806
    volumes:
      - ./:/siyuan/workspace
    command:
      - "--workspace=/siyuan/workspace/"
      - "--lang=zh_CN"
      - "--accessAuthCode=$access_password"
EOF
docker compose up -d || echo "安装失败" && exit
echo "访问密码：$access_password"
