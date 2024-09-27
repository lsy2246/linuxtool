#!/bin/bash
declare pick
echo "========$(basename $0 .sh)========"
echo "1.查看已有站点配置文件"
echo "2.删除站点配置文件"
read -p "请选择：" pick
case $pick in
'1')
  declare -a site_arr
  declare site_name
  declare site_number=0
  for i in "/etc/nginx/sites-available"/* ; do
      if [[ $i == "/etc/nginx/sites-available/*" ]];then
        echo "暂时没有配置文件"
        exit
      fi
      site_number=$(( site_number+1 ))
      site_name=$(basename $i)
      echo "${site_number}.${site_name}"
      site_arr[$site_number]=$site_name
  done
  ;;
'2')
  declare -a site_arr
  declare site_name
  declare site_number=0
  for i in "/etc/nginx/sites-available"/* ; do
      if [[ $i == "/etc/nginx/sites-available/*" ]];then
        echo "暂时没有配置文件"
        exit
      fi
      site_number=$(( site_number+1 ))
      site_name=$(basename $i)
      echo "${site_number}.${site_name}"
      site_arr[$site_number]=$site_name
  done
  read -p "请输入要删除的序号,多个用 空格 隔开：" site_name
  for i in $site_name ; do
      if [[ $i =~ [1-${#site_arr[*]}] ]]; then
          echo "开始删除 ${site_arr[$i]}"
          rm -rf "/etc/nginx/sites-available/${site_arr[$i]}" &> /dev/null
          rm -rf "/etc/nginx/sites-enabled/${site_arr[$i]}" &> /dev/null
          echo "删除完成"
      fi
  done
  echo "删除完成"
  ;;
esac