#!/bin/bash
declare path=$1
declare port=$2
cd $path
cat > "docker-compose.yml" << EOF
version: '3.8'
services:
  alist:
    image: xhofe/alist:latest
    container_name: alist
    restart: always
    volumes:
      - ./:/opt/alist/data
    ports:
      - "${port}:5244"
EOF
sudo docker compose up -d | "安装失败" $$ exit
declare password=$( docker exec -it alist ./alist admin random )
echo "账号：admin"
echo "密码：${password}"
cd - >> /dev/null
