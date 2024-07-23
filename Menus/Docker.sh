#!/bin/bash

if ! command -v docker &> /dev/null; then
    echo "docker未安装"
    bash Run.sh 
fi

declare pick_array
declare pick_number=6
declare pick

echo "========Docker========"
echo "0.返回主菜单"
echo "1.换源"
echo "-----一键搭建软件-----"
cd "Config/Docker"
for i in *;do
    pick_number=$((pick_number + 1))
    pick_array[$pick_number]=$(awk -F '.' '{print $1}' <<< "$i")
    echo "${pick_number}.${pick_array[$pick_number]}"
done
cd - >> /dev/null
echo "-----一键搭建软件-----"
echo "========Docker========"
read -p "请输入要使用的功能：" pick


if [[ "$pick" == 0 ]]; then
    clear
    bash Run.sh
elif [[ "${pick_number}" -gt 0 && "${pick}" -le "$((${#pick_array[*]}+${pick_number}))" ]];then
    clear
    bash "Config/Docker/${pick_array[${pick}]}.sh"
else
    exit
fi


