#!/bin/bash

declare pick
echo "========user========"
echo "1.新建用户"
echo "2.查看所有用户"
echo "3.删除用户"
echo "4.修改用户密码"
echo "任意输入返回主菜单"
echo "========user========"
read -p "请输入要使用的功能：" pick

case $pick in
'1')
  declare user_name
  read -p "请输入你想创建的用户名：" user_name

  if id "$user_name" &>/dev/null; then
      echo "用户 $user_name 已存在。"
      exit 1
  fi

  useradd -m -s /bin/bash "$user_name"

  if grep -q "^$user_name " /etc/sudoers;then
      sed -i "s/^#\?$user_name.*/$user_name ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers
  else
      echo "$user_name ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  fi


  declare pick
  echo "用户登录方式"
  echo "y.密码登录"
  echo "n.使用root用户公钥"
  read -p "默认y，请输入：" pick
  if [[ ! $pick =~ [Nn] ]];then
      declare password
      read -p "请输入密码：" password
      echo "$user_name:$password" |chpasswd
      sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
      echo "创建成功"
      echo "账号：$user_name"
      echo "密码：$password"
  else
      sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
      su "$user_name" -c "mkdir -p '/home/$user_name/.ssh'"
      cp "/root/.ssh/authorized_keys" "/home/$user_name/.ssh/authorized_keys"
      chown "$user_name:$user_name" "/home/$user_name/.ssh/authorized_keys"
      su "$user_name" -c "chmod 600 '/home/$user_name/.ssh/authorized_keys'"
      su "$user_name" -c "chmod 700 '/home/$user_name/.ssh/'"

      echo "创建成功"
      echo "账号：$user_name"
      echo "密钥登录"
  fi

  declare pick2
  echo "是否关闭root登录"
  read -p "输入 n 取消关闭：" pick2

  if [[ ! $pick2 =~ [Nn] ]];then
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
      echo "root用户登录已关闭"
  fi

  systemctl restart sshd.service
  ;;
'2')
  echo "当前系统有以下用户"
  cut -d: -f1 /etc/passwd
  ;;
'3')
  declare user_name
  read -p "请输入需要删除的用户：" user_name
  if ! id $user_name &> /dev/nuull ;then
    echo "系统内没有该用户"
    exit
  fi
  sed -i "/^#\?$user_name.*/d" /etc/sudoers &> /dev/null
  pkill -u $user_name
  userdel -r $user_name &> /dev/null
  rm -rf "/home/${user_name}"
  echo "用户删除成功"
  ;;
'4')
  declare password
  declare user_name
  read -p "请输入需要修改密码的用户" user_name
  if ! id $user_name;then
    echo "系统内没有该用户"
    exit
  fi
  read -p "请输入${user_name}密码：" password
  echo "${user_name}:${password}" |chpasswd
  if [[ ${user_name} == "root" ]]; then
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
  fi
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
  systemctl restart sshd.service
  echo "修改成功,用户${user_name}密码为：${password}"
  ;;
esac