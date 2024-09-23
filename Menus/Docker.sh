#!/bin/bash

declare path_script=$1
declare file_name=$(basename $0 .sh)
if ! command -v docker &> /dev/null; then
    echo "docker未安装"
    exit
fi

declare pick_array
declare pick_number=6
declare pick

echo "========Docker========"
echo "1.换源"
echo "2.清除所有未使用镜像"
echo "-----一键搭建软件-----"
for i in "${path_script}/Config/${file_name}"/*;do
    pick_number=$((pick_number + 1))
    pick_array[$pick_number]=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
    echo "${pick_number}.${pick_array[$pick_number]}"
done
echo "-----一键搭建软件-----"
echo "任意输入返回主菜单"
echo "========Docker========"
read -p "请输入要使用的功能：" pick

clear

if [[ $pick == '1' ]];then
    declare -A img_dick
    declare -a img_number
    declare img_pick=0
    img_dick['Daocloud(默认)']='https://docker.m.daocloud.io'

    for i in "${!img_dick[@]}";
    do
      img_pick=$(( img_pick+1 ))
      img_number[$img_pick]=$i
      echo "${img_pick}.${i}"
    done
    read -p "请输入要选择的镜像,也可直接输入镜像网站：" img_pick
    if [[ -z $img_pick ]];then
      declare url='https://docker.m.daocloud.io'
    elif [[ $img_pick =~ ^[http] ]];then
      declare url=$img_pick
    elif [[ ${img_pick} -le 0 || ${img_pick} -ge ${!img_dick[*]} ]];then
      img_pick=${img_number[$img_pick]}
      declare url=${img_dick[$img_pick]}
    else
      echo "输入错误"
      exit
    fi
    echo "{\"registry-mirrors\": [\"${url}\"]}" > "/etc/docker/daemon.json"
    systemctl restart docker 2>> /dev/null|| echo "docker 重启失败"
    echo "换源成功"

elif [[ $pick == '2' ]];then
  docker system prune -af
  echo "清理完成"
elif [[ "${pick}" -gt "$((${pick_number}-${#pick_array[*]}))" && "${pick}" -le "${pick_number}" ]];then
    declare file_path
    read -p "请输入软件储存位置,默认 /var/www/${pick_array[${pick}]} ："  file_path
    if [[ -z ${file_path}  ]];then
      file_path="/var/www/${pick_array[${pick}]}"
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

    bash "${path_script}/Config/${file_name}/${pick_array[${pick}]}.sh" "$file_path" "$port"
    echo "${pick_array[${pick}]}安装完成,访问端口${port}"
fi


