#!/bin/bash

declare path_script=$1
declare file_name=$(basename $0 .sh)

declare pick_array
declare pick_number=6
declare pick

echo "========$(basename $0 .sh)========"
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
    elif [[ $img_pick =~ [\w\.]+ ]];then
      declare url=$img_pick
    elif [[ ${img_pick} =~ [1-${!img_dick[*]}]  ]];then
      img_pick=${img_number[$img_pick]}
      declare url=${img_dick[$img_pick]}
    else
      echo "输入错误"
      exit
    fi
    echo "{\"registry-mirrors\": [\"${url}\"]}" > "/etc/docker/daemon.json"
    systemctl restart docker 2>> /dev/null|| echo "docker 重启失败"&&exit
    echo "换源成功"

elif [[ $pick == '2' ]];then
  docker system prune -af
  echo "清理完成"
elif [[ "${pick}" =~ [${pick_number}-${#pick_array[*]}] ]];then

fi


