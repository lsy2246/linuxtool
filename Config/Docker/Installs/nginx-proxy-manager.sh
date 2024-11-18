#!/bin/bash
declare install_path=$1
declare service_port=$2

cd $install_path
cat > docker-compose.yml << EOF
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
      - '${service_port}:81'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF
docker compose up -d
echo "Email: admin@example.com"
echo "Password: changeme"
