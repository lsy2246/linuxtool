#!/bin/bash
declare install_path=$1
declare service_port=$2
cd $install_path
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
      - "${service_port}:5244"
EOF
docker compose up -d || echo "安装失败" && exit
declare admin_password=$( docker exec -it alist ./alist admin random | grep password | awk '{print $4}')
echo "账号：admin"
echo "密码：${admin_password}"
