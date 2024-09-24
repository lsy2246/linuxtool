#!/bin/bash

if ! command -v ssh &> /dev/null; then
    echo "ssh未安装"
    exit
fi

declare path_script=$1
declare file_name=$(basename $0 .sh)
declare pick_array
declare pick_number=0

declare pick
echo "========Login========"
for i in "${path_script}/Config/${file_name}"/*;do
    pick_number=$((pick_number + 1))
    pick_array[$pick_number]=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
    echo "${pick_number}.${pick_array[$pick_number]}"
done
echo "任意输入返回主菜单"
echo "========Login========"
read -p "请输入要使用的功能：" pick

if [[ $pick =~ [1-$pick_number] ]]; then
    bash "${path_script}/Config/${file_name}/${pick_array[${pick}]}.sh"
fi