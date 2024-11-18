#!/bin/bash
declare user_choice
echo "========$(basename $0 .sh)========"
echo "1. 更换 SSH 端口"
echo "2. 修改 SSH 登录方式"
echo "任意输入返回主菜单"
read -p "请输入要使用的功能：" user_choice

case $user_choice in
'1')
  read -p "请输入需要修改的端口号（默认22）: " new_port

  if [[ -z $new_port ]];then
      new_port=22
  fi

  if ! [[ $new_port =~ ^[0-9]+$ ]] || ! ((new_port > 0 && new_port < 65535)); then
      echo "端口号不合法"
      exit
  fi

  if lsof -i :$new_port -t >/dev/null; then
      echo "$new_port 端口已被占用"
      exit
  fi

  sed -i "s/^#\?Port.*/Port $new_port/g" /etc/ssh/sshd_config

  systemctl restart sshd.service

  echo "端口已修改为$new_port，请确保防火墙放行该端口"
  ;;
'2')
  declare root_login_choice
  declare password_auth_choice
  declare key_auth_choice
  echo "是否关闭 root 用户登录"
  read -p "输入 n 关闭：" root_login_choice
  echo "是否关闭密码登录"
  read -p "输入 n 关闭：" password_auth_choice
  echo "是否关闭密钥登录"
  read -p "输入 n 关闭：" key_auth_choice

  if [[ ! $root_login_choice =~ [Nn] ]];then
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
      echo "root 用户登录：已开启"
  else
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
      echo "root 用户登录：已关闭"
  fi

  if [[ ! $password_auth_choice =~ [Nn] ]];then
      sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      echo "密码登录：已开启"
  else
      sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
      echo "密码登录：已关闭"
  fi

  if [[ ! $key_auth_choice =~ [Nn] ]];then
      sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
      echo "密钥登录：已开启"
  else
      sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication no/g' /etc/ssh/sshd_config
      echo "密钥登录：已关闭"
  fi

  systemctl restart sshd.service
  ;;
esac