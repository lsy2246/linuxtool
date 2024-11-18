#!/bin/bash

if [[ $UID != 0 ]]; then
    echo "请以root权限执行该脚本"
    exit
fi

declare -a function_array
declare selected_function
declare script_path=$(dirname $0)
script_path="${script_path}/Config"
declare local_path=$script_path
declare script_name

while true
do
if [[ -e "${local_path}/test.sh" ]]; then
    bash "${local_path}/test.sh"
    if [[ $? -eq 1 ]]; then
        local_path=$script_path
    fi
fi
if [[ -e "${local_path}/menu.sh" ]]; then
    clear
    bash "${local_path}/menu.sh" "$local_path"
    local_path=$script_path
fi
selected_function=0
function_array=()
echo "======$(basename $local_path .sh)======"
for i in "${local_path}"/*
do
    script_name=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
    if [[ $script_name == "test" ]]; then
      continue
    fi
    selected_function=$((selected_function + 1))
    function_array[$selected_function]=$script_name
    echo "${selected_function}.${function_array[$selected_function]}"
done

if [[ $local_path != $script_path  ]]; then
    echo "输入任意返回主页"
fi

read -p "请输入要使用的功能：" user_choice
if [[ "${user_choice}" =~ [1-${#function_array[*]}] ]];then
    clear
    if [[ -d "${local_path}/${function_array[$user_choice]}" ]]; then
      local_path="${local_path}/${function_array[$user_choice]}"
    elif [[ -e "${local_path}/${function_array[$user_choice]}.sh" ]]; then
      bash "${local_path}/${function_array[$user_choice]}.sh"
      local_path=$script_path
    fi
else
  if [[ $local_path == $script_path  ]]; then
      exit
  fi
  local_path=$script_path
fi

done