#!/bin/bash

if ! command -v sudo &> /dev/null; then
    echo "该软件需要安装sudo才能正常安装"
    exit
fi

declare installation_directory=$1
declare web_service_port=$2

sudo useradd -m git
sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key" -f /home/git/.ssh/id_rsa -N ""
sudo -u git sh -c 'cat /home/git/.ssh/id_rsa.pub >> /home/git/.ssh/authorized_keys'
sudo -u git sh -c 'chmod a+x /usr/local/bin/gitea'
sudo -u git sh -c 'echo "ssh -p '$(( web_service_port+22 ))' -o StrictHostKeyChecking=no git@127.0.0.1 \"SSH_ORIGINAL_COMMAND=\\\"\$SSH_ORIGINAL_COMMAND\\\" \$0 \$@\"" > /usr/local/bin/gitea'
declare user_id=$( id git | awk -F'[=() ]+' '{print $2}' )
declare group_id=$( id git | awk -F'[=() ]+' '{print $5}' )

cd $installation_directory
cat > "docker-compose.yml" << EOF
networks:
  gitea:
    external: false
services:
  server:
    image: gitea/gitea:latest
    container_name: gitea
    environment:
      - USER_UID=${user_id}
      - USER_GID=${group_id}
      - GITEA__database__DB_TYPE=mysql
      - GITEA__database__HOST=db:3306
      - GITEA__database__NAME=gitea
      - GITEA__database__USER=gitea
      - GITEA__database__PASSWD=gitea
    restart: always
    networks:
      - gitea
    volumes:
      - ./data:/data
      - /etc/timezone:/etc/timezone:ro
      - /etc/localtime:/etc/localtime:ro
      - /home/git/.ssh/:/data/git/.ssh
    ports:
      - "${web_service_port}:3000"
      - "$(( web_service_port+22 )):22"
    depends_on:
      - db
  db:
    image: mysql:8
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=gitea
      - MYSQL_USER=gitea
      - MYSQL_PASSWORD=gitea
      - MYSQL_DATABASE=gitea
    networks:
      - gitea
    volumes:
      - ./mysql:/var/lib/mysql
EOF
chown -R git:git $installation_directory
sudo docker compose up -d

