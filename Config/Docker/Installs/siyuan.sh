#!/bin/bash
declare path=$1
declare port=$2
declare password
read -p "请输入思源访问密码,(默认 Siyuan )：" password

if [[ -z $password ]];then
	password="Siyuan"
fi

chown -R 1000:1000 $path
cd $path
cat > "docker-compose.yml" << EOF
version: "3.9"
services:
  siyuan:
    image: b3log/siyuan
    container_name: siyuan
    user: '1000:1000'
    restart: always
    ports:
      - $port:6806
    volumes:
      - ./:/siyuan/workspace
    command:
      - "--workspace=/siyuan/workspace/"
      - "--lang=zh_CN"
      - "--accessAuthCode=$password"
EOF
docker compose up -d || "安装失败" $$ exit
echo "访问密码：$password"
