#!/bin/bash
echo "1.查看已经安装的脚本"
echo "2.删除脚本"

declare pick
read -p "请输入：" pick

declare path="/var/script"
echo "请输入脚本安装地址,默认${path}"
read -p "请输入：" path

if [[ -z $path ]]; then
    path="/var/script"
elif ! [[ -d $path ]]; then
    echo "该地址不存在目录"
fi

case $pick in
'1')
  for i in "$path"/* ; do
      if [[ $i == "${path}/*" ]];then
        echo "该地址不存在脚本"
      fi
      basename $i
  done
  ;;
'2')
  declare -a script_arr
  declare script_name
  declare script_number=0
  for i in "$path"/* ; do
      if [[ $i == "${path}/*" ]];then
        echo "该地址不存在脚本"
        exit 
      fi
      script_name=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
      if [[ $script_name == "linuxtool" ]]; then
          continue
      fi
      script_number=$(( script_number+1 ))
      echo "${script_number}.${script_name}"
      script_arr[$script_number]=$script_name
  done
  read -p "请输入要删除的序号,多个用 空格 隔开：" script_name
  for i in $script_name ; do
      if [[ $i =~ [1-${#script_arr[*]}] ]]; then
          echo "开始删除 ${script_arr[$i]}"
          (crontab -l 2>/dev/null | grep -v "${script_arr[$i]}") | crontab - && echo "已经删除脚本的自动任务"
          rm -rf "$path/${script_arr[$i]}" &> /dev/null
          echo "删除完成"
      fi
  done
  echo "删除完成"
  ;;
esac