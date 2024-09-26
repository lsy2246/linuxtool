#!/bin/bash
declare path_local=$1
declare pick
declare file_name
echo "========$(basename $0 .sh)========"
declare print_number=0
declare -a print_array
for i in "${path_local}"/*;do
    file_name=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
    if [[ $file_name == "test" || $file_name == "menu" ]]; then
      continue
    fi
    print_number=$((print_number + 1))
    print_array[$print_number]=$file_name
    echo "${print_number}.${file_name}"
done
echo "输入其他任意返回主页"
read -p "请输入：" pick

if [[ ! ${pick} =~ [1-$print_number] ]];then
  exit
fi

declare file_path
read -p "请输入软件储存位置,默认 /var/www/${print_array[${pick}]} ："  file_path
if [[ -z ${file_path}  ]];then
  file_path="/var/www/${print_array[${pick}]}"
fi

if [[ ! -d "$file_path"  ]];then
    sudo mkdir -p "$file_path" || { echo "目录创建失败"; exit 1; }
elif [[ ! -z "$(find "$file_path" -mindepth 1 -print -quit)" ]];then
    echo "该目录存有文件"
    exit
fi

declare dport=$(($RANDOM % 9000 + 1000))

while ss -tuln | grep $dport &> /dev/null
do
   dport=$(($RANDOM % 9000 + 1000))
done

declare port
read -p "请输入访问端口,默认 $dport ："  port

if [[ -z $port  ]];then
  port=$dport
fi

if ss -tuln | grep $port &> /dev/null;then
  echo "端口已被占用"
  exit
fi

bash "${path_local}/${print_array[pick]}.sh" "$file_path" "$port"
echo "${print_array[${pick}]}安装完成,访问端口${port}"