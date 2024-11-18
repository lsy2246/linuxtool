#!/bin/bash
echo "========$(basename $0 .sh)========"
echo "1. 查看当前源"
echo "2. 换源"
declare user_choice
read -p "请输入：" user_choice

case $user_choice in
'1')
  grep -oP '(https?://[^\"]+)' /etc/docker/daemon.json
  ;;
'2')
  declare -A mirror_options
  declare -a mirror_list
  declare mirror_choice=0
  mirror_options['Daocloud(默认)']='https://docker.m.daocloud.io'
  mirror_options['官方']='docker.io'

  for mirror in "${!mirror_options[@]}";
  do
    mirror_choice=$(( mirror_choice+1 ))
    mirror_list[$mirror_choice]=$mirror
    echo "${mirror_choice}.${mirror}"
  done
  read -p "请输入要选择的镜像，也可直接输入镜像网站：" selected_mirror
  if [[ -z $selected_mirror ]];then
    declare url='https://docker.m.daocloud.io'
  elif [[ $selected_mirror =~ [\w\.]+ ]];then
    declare url=$selected_mirror
  elif [[ ${selected_mirror} =~ [1-${!mirror_options[*]}]  ]];then
    selected_mirror=${mirror_list[$selected_mirror]}
    declare url=${mirror_options[$selected_mirror]}
  else
    echo "输入错误"
    exit
  fi
  echo "正在写入配置文件"
  echo "{\"registry-mirrors\": [\"${url}\"]}" > "/etc/docker/daemon.json"
  echo "正在重启 Docker"
  systemctl restart docker 2>> /dev/null  || echo "Docker 重启失败"&&exit
  echo "换源成功"

  ;;
esac