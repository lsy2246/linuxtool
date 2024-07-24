#!/bin/bash
declare path=$1
declare port=$2
cd $path
wget "https://waf-ce.chaitin.cn/release/latest/compose.yaml"

cat > ".env" << EOF
SAFELINE_DIR=$path
IMAGE_TAG=latest
MGT_PORT=$port
POSTGRES_PASSWORD="safeline"
SUBNET_PREFIX=172.22.222
IMAGE_PREFIX=chaitin
EOF
sudo docker compose up -d || "安装失败" $$ exit
declare password=$( docker exec safeline-mgt resetadmin | grep password | awk -F "：" '{print $2}' )
echo "账号：admin"
echo "密码：${password}"
