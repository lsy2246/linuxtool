#!/bin/bash
declare installation_directory=$1
declare management_port=$2
cd $installation_directory
wget "https://waf-ce.chaitin.cn/release/latest/compose.yaml"

cat > ".env" << EOF
SAFELINE_DIR=$installation_directory
IMAGE_TAG=latest
MGT_PORT=$management_port
POSTGRES_PASSWORD="safeline"
SUBNET_PREFIX=172.22.222
IMAGE_PREFIX=swr.cn-east-3.myhuaweicloud.com/chaitin-safeline
EOF
docker compose up -d || echo "安装失败" && exit
declare admin_password=$( docker exec safeline-mgt resetadmin &> /dev/null | grep password | awk -F "：" '{print $2}' )
echo "账号：admin"
echo "密码：${admin_password}"
