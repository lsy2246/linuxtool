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


elif [[ $pick == '2' ]];then

elif [[ "${pick}" =~ [${pick_number}-${#pick_array[*]}] ]];then

fi


