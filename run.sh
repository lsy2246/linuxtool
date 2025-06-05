#!/bin/bash

if [[ $UID != 0 ]]; then
  echo "请以root权限执行该脚本"
  exit
fi

declare -a function_array
declare selected_function
declare script_path=$(dirname $(readlink -f $0))
script_path="${script_path}/Config"
declare local_path=$script_path
declare script_name

while true; do
  # 1. 目录初始化脚本 _init.sh
  if [[ -e "${local_path}/_init.sh" ]]; then
    bash "${local_path}/_init.sh"
    if [[ $? -eq 1 ]]; then
      local_path=$script_path
      continue
    fi
  fi

  # 2. 完全替代菜单 _menu.sh
  if [[ -e "${local_path}/_menu.sh" ]]; then
    clear
    bash "${local_path}/_menu.sh" "$local_path"
    local_path=$script_path
    continue
  fi

  # 默认菜单逻辑
  selected_function=0
  function_array=()
  echo "======$(basename $local_path .sh)======"
  for i in "${local_path}"/*; do
    script_name=$(awk -F '.' '{print $1}' <<<"$(basename $i)")
    # 忽略特殊文件
    if [[ $script_name =~ ^_ ]]; then
      continue
    fi
    selected_function=$((selected_function + 1))
    function_array[$selected_function]=$script_name
    echo "${selected_function}.${function_array[$selected_function]}"
  done

  if [[ $local_path != $script_path ]]; then
    echo "输入任意返回主页"
  fi

  read -p "请输入要使用的功能：" user_choice
  if [[ "$user_choice" =~ ^[0-9]+$ ]] && [ "$user_choice" -ge 1 ] && [ "$user_choice" -le "${#function_array[*]}" ]; then
    clear
    selected_script="${function_array[$user_choice]}"

    if [[ -d "${local_path}/${selected_script}" ]]; then
      # 进入子目录
      local_path="${local_path}/${selected_script}"
    elif [[ -e "${local_path}/${selected_script}.sh" ]]; then
      # 3. 检查是否存在 _action.sh（半替代菜单）
      if [[ -e "${local_path}/_action.sh" ]]; then
        # 将用户选择的脚本名称和当前路径传递给 _action.sh
        bash "${local_path}/_action.sh" "$local_path" "${selected_script}"
      else
        # 直接执行用户选择的脚本
        bash "${local_path}/${selected_script}.sh"
      fi
      local_path=$script_path
    fi
  else
    if [[ $local_path == $script_path ]]; then
      exit
    fi
    local_path=$script_path
  fi

done
