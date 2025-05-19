#!/bin/bash
if ! command -v socat &> /dev/null; then
    if [[ -f "/usr/bin/apt-get" ]];then
      apt-get update -y
      apt-get install socat -y
    elif [[ -f "/usr/bin/apt" ]];then
      apt update -y
      apt install socat -y
    elif [[ -f "/usr/bin/pacman" ]];then
      pacman -Syu --noconfirm
      pacman -Sy --noconfirm socat
    else
      echo "socat未安装，请手动安装"
      exit
    fi
fi

if [[ ! -f "${HOME}/.acme.sh/acme.sh" ]];then
  rm -rf ${HOME}/.apple.sh
  declare email_address
  read -p "请输入用来申请域名的邮箱：" email_address
  if [[ ! $email_address =~ .*@.* ]];then
        echo "邮箱不合法"
        exit
      fi

  curl https://get.acme.sh | sh -s "email=$email_address"
fi
