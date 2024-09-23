#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "请以root权限执行该脚本"
    exit
fi

declare -a pick_array
declare pick_number
declare pick
declare path_script=$(dirname $0)

while true
do

pick_number=0
echo "======Linux工具箱======"
for i in "${path_script}/Menus"/*
do
    pick_number=$((pick_number + 1))
    pick_array[$pick_number]=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
    echo "${pick_number}.${pick_array[$pick_number]}"
done
echo "======Linux工具箱======"
read -p "请输入要使用的功能：" pick
if [[ "${pick}" -gt 0 && "${pick}" -le "${#pick_array[*]}" ]];then
    clear
    bash "${path_script}/Menus/${pick_array[$pick]}.sh" "$path_script"
else
    exit
fi

done