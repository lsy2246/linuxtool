#!/bin/bash
echo "========key========"
echo "1.生成密钥"
echo "2.安装密钥"
echo "输入其他返回主页"
declare pick
echo "========key========"
read -p "请输入要选择的命令：" pick

case $pick in
'1')
  declare site="${HOME}/.ssh"
  read -p "请输入密钥安装位置,默认 ：${site}：" pick

  if [[ -d $pick ]]; then
      site=$pick
  elif [[ ! -z $pick ]];then
    echo "该路径没有文件夹"
    exit
  fi

  declare bit=""
  declare type=""
  declare phrase=""
  declare -A type_dick
  type_dick['rsa']="2048 4096"
  type_dick['ed25519']=""

  declare print_number=0
  declare -a print_arr
  for i in "${!type_dick[@]}" ; do
      print_number=$(( print_number+1 ))
      print_arr[$print_number]=$i
      echo "${print_number}.${i}"
  done
  read -p "请选择要生成的密钥类型：" pick
  if ! [[ $pick =~ [1-${#type_dick[@]}] ]]; then
      echo "选择错误"
      exit
  fi
  type=${print_arr[$pick]}

  if [ ! -z "${type_dick[$type]}" ]; then
      print_number=0
      echo "请选择密钥位大小"
      for i in ${type_dick[$type]} ; do
            print_number=$(( print_number+1 ))
            print_arr[$print_number]=$i
            echo "${print_number}.${i}"
      done
      read -p "请选择：" pick
      if ! [[ $pick =~ [1-${#print_arr[@]}] ]]; then
            echo "选择错误"
            exit
      fi
      bit="-b ${print_arr[$pick]}"
  fi

  read -p "是否开启密钥短语,输入y开启,请输入:" pick
  if [[ $pick =~ [Yy] ]]; then
      read -p "请输入要设置的密钥短语" phrase
  fi
  eval "ssh-keygen -t ${type} ${bit} -N '${phrase}' -f '${site}/key'  -q"
  echo "密钥安装成功"
  echo "私钥：${site}/key"
  echo "公钥：${site}/key.pub"
  read -p "是否开启密钥登录,输入n取消：" pick
  if ! [[ $pick =~ [Nn] ]]; then
      mkdir -p "$HOME/.ssh"
      echo "${site}/key.pub" > "$HOME/.ssh/authorized_keys"
      open_key
  fi
  ;;
'2')
declare key
echo "请输入公钥或文件路径："
echo "默认：$HOME/.ssh/id_rsa.pub"
read -p "回车默认：" key

if [[ -z $key ]];then
    key="$HOME/.ssh/id_rsa.pub"
fi

if [[ -f $key ]];then
    key=$(cat "$key")
fi
if [[ ! $key =~ ^ssh-(rsa|ecdsa-sha2-nistp[0-9]+|ed25519|dss) ]];then
    echo "公钥不合法"
    exit 1
fi

mkdir -p "$HOME/.ssh"
echo "$key" > "$HOME/.ssh/authorized_keys"
open_key
esac

function open_key() {
    chmod 600 "$HOME/.ssh/authorized_keys"
    chmod 700 "$HOME/.ssh"

    sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config

    declare pick2
    echo "是否关闭密码登录："
    read -p "输入 n 取消关闭：" pick2

    if [[ ! $pick2 =~ [Nn] ]];then
        sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
    fi

    systemctl restart sshd.service

    echo "密钥安装完成"
}