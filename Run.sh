#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "请以root权限执行该脚本"
    exit
fi

declare -a pick_array
declare pick_number
declare pick
declare path_script=$(dirname $0)
path_script="${path_script}/Config"
declare path_local=$path_script
declare file_name

while true
do
if [[ -e "${path_local}/test.sh" ]]; then
    bash "${path_local}/test.sh"
fi
pick_number=0
echo "======$(basename $0 .sh)======"
for i in "${path_local}"/*
do
    file_name=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
    if [[ $file_name == "test" ]]; then
      continue
    fi
    pick_number=$((pick_number + 1))
    pick_array[$pick_number]=$file_name
    echo "${pick_number}.${pick_array[$pick_number]}"
done

if [[ $path_local != $path_script  ]]; then
    echo "输入任意返回主页"
fi

read -p "请输入要使用的功能：" pick
if [[ "${pick}" =~ [1-${#pick_array[*]}] ]];then
    clear
    if [[ -d "${path_local}/${pick_array[$pick]}" ]]; then
      path_local="${path_local}/${pick_array[$pick]}"
    elif [[ -e "${path_script}/${pick_array[$pick]}.sh" ]]; then
      bash "${path_script}/${pick_array[$pick]}.sh"
      path_local=$path_script
    fi
else
  if [[ $path_local == $path_script  ]]; then
      exit
  fi
  path_local=$path_script
fi

done