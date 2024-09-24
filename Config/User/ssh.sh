#!/bin/bash
declare pick
echo "========ssh========"
echo "1.更换ssh端口"
echo "2.修改ssh登录方式"
echo "任意输入返回主菜单"
echo "========ssh========"
read -p "请输入要使用的功能：" pick

case $pick in
'1')
  read -p "请输入需要修改的端口号(默认22): " port_number

  if [[ -z $port_number ]];then
      port_number=22
  fi

  if ! [[ $port_number =~ ^[0-9]+$ ]] || ! ((port_number > 0 && port_number < 65535)); then
      echo "端口不合法"
      exit
  fi

  if lsof -i :$port_number -t >/dev/null; then
      echo "$port_number 端口已被占用"
      exit
  fi

  sed -i "s/^#\?Port.*/Port $port_number/g" /etc/ssh/sshd_config

  systemctl restart sshd.service

  echo "端口已经修改为$port_number，记得防火墙放行"
  ;;
'2')
  declare pick_root
  declare pick2_key
  declare pick2_password
  echo "是否关闭root登录"
  read -p "输入 n 关闭：" pick_root
  echo "是否关闭密码登录"
  read -p "输入 n 关闭：" pick2_password
  echo "是否关闭密钥登录"
  read -p "输入 n 关闭：" pick2_key

  if [[ ! $pick_root =~ [Nn] ]];then
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
      echo "root用户登录：开启"
  else
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
      echo "root用户登录：关闭"
  fi

  if [[ ! $pick2_password =~ [Nn] ]];then
      sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
      echo "密码登录：开启"
  else
      sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
      echo "密码登录：关闭"
  fi

  if [[ ! $pick2_key =~ [Nn] ]];then
      sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
      echo "密钥登录：开启"
  else
      sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication no/g' /etc/ssh/sshd_config
      echo "密钥登录：关闭"
  fi

  systemctl restart sshd.service
  ;;
esac