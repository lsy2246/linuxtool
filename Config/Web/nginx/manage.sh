#!/bin/bash
declare user_choice
echo "========$(basename $0 .sh)========"
echo "1.查看已有站点配置文件"
echo "2.删除站点配置文件"
read -p "请选择操作：" user_choice
case $user_choice in
'1')
  declare -a site_array
  declare site_name
  declare site_count=0
  for i in "/etc/nginx/sites-available"/* ; do
      if [[ $i == "/etc/nginx/sites-available/*" ]];then
        echo "暂时没有配置文件"
        exit
      fi
      site_count=$(( site_count+1 ))
      site_name=$(basename $i)
      echo "${site_count}.${site_name}"
      site_array[$site_count]=$site_name
  done
  if [ ${#site_array[@]} == 0 ]; then
      echo "暂时没有配置文件"
      exit
  fi
  ;;
'2')
  declare -a site_array
  declare site_name
  declare site_count=0
  for i in "/etc/nginx/sites-available"/* ; do
      if [[ $i == "/etc/nginx/sites-available/*" ]];then
        echo "暂时没有配置文件"
        exit
      fi
      site_count=$(( site_count+1 ))
      site_name=$(basename $i)
      echo "${site_count}.${site_name}"
      site_array[$site_count]=$site_name
  done
  if [ ${#site_array[@]} == 0 ]; then
      echo "暂时没有配置文件"
      exit
  fi
  read -p "请输入要删除的序号,多个用 空格 隔开：" site_name
  for i in $site_name ; do
      if [[ $i =~ [1-${#site_array[*]}] ]]; then
          echo "开始删除 ${site_array[$i]}"
          rm -rf "/etc/nginx/sites-available/${site_array[$i]}" &> /dev/null
          rm -rf "/etc/nginx/sites-enabled/${site_array[$i]}" &> /dev/null
          echo "删除完成"
      fi
  done
  echo "删除完成"
  ;;
esac