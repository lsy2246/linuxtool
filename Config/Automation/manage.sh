#!/bin/bash
echo "1. 查看已安装的脚本"
echo "2. 删除脚本"

declare user_choice
read -p "请输入您的选择：" user_choice

declare script_directory="/var/script"
echo "请输入脚本安装目录，默认是 ${script_directory}"
read -p "请输入：" script_directory

if [[ -z $script_directory ]]; then
    script_directory="/var/script"
elif ! [[ -d $script_directory ]]; then
    echo "该目录不存在"
fi

case $user_choice in
'1')
  declare -a installed_scripts
  declare script_name
  declare script_count=0
  for script in "$script_directory"/* ; do
      if [[ $script == "${script_directory}/*" ]];then
        echo "该目录没有脚本"
        exit
      fi
      script_name=$(awk -F '.' '{print $1}' <<< "$(basename $script)")
      if [[ $script_name == "linuxtool" ]]; then
          continue
      fi
      script_count=$(( script_count+1 ))
      echo "${script_count}.${script_name}"
      installed_scripts[$script_count]=$script_name
  done
  if [ ${#installed_scripts[@]} == 0 ]; then
      echo "该目录没有脚本"
      exit
  fi
  ;;
'2')
  declare -a installed_scripts
  declare script_name
  declare script_count=0
  for script in "$script_directory"/* ; do
      if [[ $script == "${script_directory}/*" ]];then
        echo "该目录没有脚本"
        exit
      fi
      script_name=$(awk -F '.' '{print $1}' <<< "$(basename $script)")
      if [[ $script_name == "linuxtool" ]]; then
          continue
      fi
      script_count=$(( script_count+1 ))
      echo "${script_count}.${script_name}"
      installed_scripts[$script_count]=$script_name
  done
  if [ ${#installed_scripts[@]} == 0 ]; then
      echo "该目录没有脚本"
      exit
  fi
  read -p "请输入要删除的序号（多个用空格隔开）：" script_name
  for i in $script_name ; do
      if [[ $i =~ [1-${#installed_scripts[@]}] ]]; then
          echo "开始删除 ${installed_scripts[$i]}"
          (crontab -l 2>/dev/null | grep -v "${installed_scripts[$i]}") | crontab - && echo "已删除脚本的自动任务"
          rm -rf "$script_directory/${installed_scripts[$i]}" &> /dev/null
          echo "删除完成"
      fi
  done
  ;;
esac