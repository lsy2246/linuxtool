#!/bin/bash
declare local_directory=$1
declare user_choice
declare selected_file_name
echo "========$(basename $0 .sh)========"
declare file_count=0
declare -a file_array
for file in "${local_directory}"/*; do
  selected_file_name=$(awk -F '.' '{print $1}' <<<"$(basename $file)")
  if [[ $selected_file_name == "test" || $selected_file_name == "menu" ]]; then
    continue
  fi
  file_count=$((file_count + 1))
  file_array[$file_count]=$selected_file_name
  echo "${file_count}.${selected_file_name}"
done
echo "输入其他字符返回主页"
read -p "请输入：" user_choice

if [[ ! "$user_choice" =~ ^[0-9]+$ ]] || [ "$user_choice" -lt 1 ] || [ "$user_choice" -gt "$file_count" ]; then
  exit
fi

declare storage_path
read -p "请输入软件存储位置，默认 /var/www/${file_array[${user_choice}]} ：" storage_path
if [[ -z ${storage_path} ]]; then
  storage_path="/var/www/${file_array[${user_choice}]}"
fi

if [[ ! -d "$storage_path" ]]; then
  mkdir -p "$storage_path" || {
    echo "目录创建失败"
    exit 1
  }
elif [[ ! -z "$(find "$storage_path" -mindepth 1 -print -quit)" ]]; then
  echo "该目录存有文件"
  exit
fi

declare random_port=$(($RANDOM % 9000 + 1000))

while ss -tuln | grep $random_port &>/dev/null; do
  random_port=$(($RANDOM % 9000 + 1000))
done

declare access_port
read -p "请输入访问端口，默认 $random_port ：" access_port

if [[ -z $access_port ]]; then
  access_port=$random_port
fi

if ss -tuln | grep $access_port &>/dev/null; then
  echo "端口已被占用"
  exit
fi

bash "${local_directory}/${file_array[user_choice]}.sh" "$storage_path" "$access_port"
echo "${file_array[${user_choice}]} 安装完成，访问端口 ${access_port}"
