#!/bin/bash
declare path=$1
declare port=$2

cd $path
cat > docker-compose.yml << EOF
services:
  app:
    image: 'jc21/nginx-proxy-manager:latest'
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
      - '${port}:81'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
EOF
sudo docker compose up -d
echo "Email:    admin@example.com"
echo "Password: changeme"
