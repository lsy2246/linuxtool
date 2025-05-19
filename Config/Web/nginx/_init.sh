#!/bin/bash

if ! command -v nginx &> /dev/null; then
    if [[ -f "/usr/bin/apt-get" ]];then
      apt-get update -y
      apt-get install nginx -y
    elif [[ -f "/usr/bin/apt" ]];then
      apt update -y
      apt install nginx -y
    elif [[ -f "/usr/bin/pacman" ]];then
      pacman -Syu --noconfirm
      pacman -Sy --noconfirm nginx
    else
      echo "nginx未安装，请手动安装"
      exit
    fi
fi