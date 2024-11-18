#!/bin/bash
declare installation_directory=$1
declare web_service_port=$2

cd $installation_directory
cat > docker-compose.yml << EOF
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
      - '${web_service_port}:81'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF
docker compose up -d
echo "管理员邮箱: admin@example.com"
echo "管理员密码: changeme"
