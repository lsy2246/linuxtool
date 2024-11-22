#!/bin/bash
echo "========$(basename $0 .sh)========"
echo "1. 生成密钥"
echo "2. 安装密钥"
echo "输入其他字符返回主页"
declare user_choice
read -p "请输入要选择的命令：" user_choice

function configure_key() {
    chmod 600 "$HOME/.ssh/authorized_keys"
    chmod 700 "$HOME/.ssh"

    sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config

    declare user_input
    echo "是否关闭密码登录："
    read -p "输入 n 取消关闭：" user_input

    if [[ ! $user_input =~ [Nn] ]];then
        sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
    fi

    systemctl restart sshd.service

    echo "密钥安装完成"
}

case $user_choice in
'1')
  declare key_directory="${HOME}/.ssh"
  read -p "请输入密钥安装位置, 默认：${key_directory}：" user_input

  if [[ -d $user_input ]]; then
      key_directory=$user_input
  elif [[ ! -z $user_input ]];then
    echo "该路径没有文件夹"
    exit
  fi

  declare key_size=""
  declare key_type=""
  declare passphrase=""
  declare -A key_options
  key_options['rsa']="2048 4096"
  key_options['ed25519']=""

  declare option_count=0
  declare -a option_array
  for i in "${!key_options[@]}" ; do
      option_count=$(( option_count+1 ))
      option_array[$option_count]=$i
      echo "${option_count}.${i}"
  done
  read -p "请选择要生成的密钥类型：" user_input
  if ! [[ $user_input =~ [1-${#key_options[@]}] ]]; then
      echo "选择错误"
      exit
  fi
  key_type=${option_array[$user_input]}

  if [ ! -z "${key_options[$key_type]}" ]; then
      option_count=0
      echo "请选择密钥位大小"
      for i in ${key_options[$key_type]} ; do
            option_count=$(( option_count+1 ))
            option_array[$option_count]=$i
            echo "${option_count}.${i}"
      done
      read -p "请选择：" user_input
      if ! [[ $user_input =~ [1-${#option_array[@]}] ]]; then
            echo "选择错误"
            exit
      fi
      key_size="-b ${option_array[$user_input]}"
  fi

  read -p "是否开启密钥短语，输入y开启，请输入：" user_input
  if [[ $user_input =~ [Yy] ]]; then
      read -p "请输入要设置的密钥短语：" passphrase
  fi
  eval "ssh-keygen -t ${key_type} ${key_size} -N '${passphrase}' -f '${key_directory}/key' -q"
  echo "密钥安装成功"
  echo "私钥：${key_directory}/key"
  echo "公钥：${key_directory}/key.pub"
  read -p "是否开启密钥登录，输入n取消：" user_input
  if ! [[ $user_input =~ [Nn] ]]; then
      mkdir -p "$HOME/.ssh"
      echo "${key_directory}/key.pub" > "$HOME/.ssh/authorized_keys"
      configure_key
  fi
  ;;
'2')
declare public_key
echo "请输入公钥或文件路径："
echo "默认：$HOME/.ssh/id_rsa.pub"
read -p "回车默认：" public_key

if [[ -z $public_key ]];then
    public_key="$HOME/.ssh/id_rsa.pub"
fi

if [[ -f $public_key ]];then
    public_key=$(cat "$public_key")
fi
if [[ ! $public_key =~ ^ssh-(rsa|ecdsa-sha2-nistp[0-9]+|ed25519|dss) ]];then
    echo "公钥不合法"
    exit 1
fi

mkdir -p "$HOME/.ssh"
echo "$public_key" > "$HOME/.ssh/authorized_keys"
configure_key
esac

