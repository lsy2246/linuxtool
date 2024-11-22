#!/bin/bash

declare user_choice
echo "========$(basename $0 .sh)========"
echo "1. 新建用户"
echo "2. 查看所有用户"
echo "3. 删除用户"
echo "4. 修改用户密码"
echo "任意输入返回主菜单"
read -p "请输入要使用的功能：" user_choice

case $user_choice in
'1')
  declare new_user_name
  read -p "请输入要创建的用户名：" new_user_name

  if id "$new_user_name" &>/dev/null; then
      echo "用户 $new_user_name 已存在。"
      exit 1
  fi

  useradd -m -s /bin/bash "$new_user_name"

  if grep -q "^$new_user_name " /etc/sudoers;then
      sed -i "s/^#\?$new_user_name.*/$new_user_name ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers
  else
      echo "$new_user_name ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
  fi

  declare login_method_choice
  echo "用户登录方式"
  echo "y. 密码登录"
  echo "n. 使用 root 用户公钥"
  read -p "默认 y，请输入：" login_method_choice
  if [[ ! $login_method_choice =~ [Nn] ]];then
      declare user_password
      read -p "请输入密码：" user_password
      echo "$new_user_name:$user_password" |chpasswd
      sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
      echo "创建成功"
      echo "账号：$new_user_name"
      echo "密码：$user_password"
  else
      sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
      su "$new_user_name" -c "mkdir -p '/home/$new_user_name/.ssh'"
      cp "/root/.ssh/authorized_keys" "/home/$new_user_name/.ssh/authorized_keys"
      chown "$new_user_name:$new_user_name" "/home/$new_user_name/.ssh/authorized_keys"
      su "$new_user_name" -c "chmod 600 '/home/$new_user_name/.ssh/authorized_keys'"
      su "$new_user_name" -c "chmod 700 '/home/$new_user_name/.ssh/'"

      echo "创建成功"
      echo "账号：$new_user_name"
      echo "密钥登录"
  fi

  declare root_login_choice
  echo "是否关闭 root 用户登录"
  read -p "输入 n 取消关闭：" root_login_choice

  if [[ ! $root_login_choice =~ [Nn] ]];then
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
      echo "root 用户登录已关闭"
  fi

  systemctl restart sshd.service
  ;;
'2')
  echo "当前系统有以下用户"
  cut -d: -f1 /etc/passwd
  ;;
'3')
  declare user_to_delete
  read -p "请输入需要删除的用户名：" user_to_delete
  if ! id $user_to_delete &> /dev/null ;then
    echo "系统内没有该用户"
    exit
  fi
  sed -i "/^#\?$user_to_delete.*/d" /etc/sudoers &> /dev/null
  pkill -u $user_to_delete
  userdel -r $user_to_delete &> /dev/null
  rm -rf "/home/${user_to_delete}"
  echo "用户删除成功"
  ;;
'4')
  declare new_password
  declare user_name
  read -p "请输入需要修改密码的用户名：" user_name
  if ! id $user_name &> /dev/null;then
    echo "系统内没有该用户"
    exit
  fi
  read -p "请输入${user_name}的新密码：" new_password
  echo "${user_name}:${new_password}" |chpasswd
  if [[ ${user_name} == "root" ]]; then
      sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
  fi
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
  systemctl restart sshd.service
  echo "修改成功, 用户 ${user_name} 的新密码为：${new_password}"
  ;;
esac