#!/bin/bash

if ! command -v sudo &> /dev/null; then
    echo "sudo未安装,部分命令无法正常运行"
fi


declare -a pick_array
declare pick_number=0

declare pick
echo "======Linux工具箱======"
cd Menus
for i in *
do
    pick_number=$((pick_number + 1))
    pick_array[$pick_number]=$(awk -F '.' '{print $1}' <<< "$i")
    echo "${pick_number}.${pick_array[$pick_number]}"
done
cd - >> /dev/null
echo "======Linux工具箱======"
read -p "请输入要使用的功能：" pick
if [[ "${pick}" -gt 0 && "${pick}" -le "${#pick_array[*]}" ]];then
    clear
    bash Menus/${pick_array[$pick]}.sh
else
    exit
fi