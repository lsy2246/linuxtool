#!/bin/bash

if ! command -v sudo &> /dev/null; then
    echo "该软件需要安装sudo才能正常安装"
    exit
fi

declare path=$1
declare port=$2

sudo useradd -m git
sudo -u git ssh-keygen -t rsa -b 4096 -C "Gitea Host Key" -f /home/git/.ssh/id_rsa -N ""
sudo -u git sh -c 'cat /home/git/.ssh/id_rsa.pub >> /home/git/.ssh/authorized_keys'
declare uid=$( id git | awk -F'[=() ]+' '{print $2}' )
declare gid=$( id git | awk -F'[=() ]+' '{print $5}' )

cd $path
cat > "docker-compose.yml" << EOF
networks:
  gitea:
    external: false
services:
  server:
    image: gitea/gitea:latest
    container_name: gitea
    environment:
      - USER_UID=${uid}
      - USER_GID=${gid}
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
      - "${port}:3000"
      - "$(( port+22 )):22"
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
chown -R git:git $path
sudo docker compose up -d

sudo -u git ssh -p $(( port+22 )) -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=\"$SSH_ORIGINAL_COMMAND\" $0 $@"

