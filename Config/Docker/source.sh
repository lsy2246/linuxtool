#!/bin/bash
echo "========$(basename $0 .sh)========"
echo "1.查看当前源"
echo "2.换源"
declare pick
read -p "请输入：" pick

case $pick in
'1')
  grep -oP '(https?://[^\"]+)' /etc/docker/daemon.json
  ;;
'2')
  declare -A img_dick
  declare -a img_number
  declare img_pick=0
  img_dick['Daocloud(默认)']='https://docker.m.daocloud.io'
  img_dick['官方']='docker.io'

  for i in "${!img_dick[@]}";
  do
    img_pick=$(( img_pick+1 ))
    img_number[$img_pick]=$i
    echo "${img_pick}.${i}"
  done
  read -p "请输入要选择的镜像,也可直接输入镜像网站：" img_pick
  if [[ -z $img_pick ]];then
    declare url='https://docker.m.daocloud.io'
  elif [[ $img_pick =~ [\w\.]+ ]];then
    declare url=$img_pick
  elif [[ ${img_pick} =~ [1-${!img_dick[*]}]  ]];then
    img_pick=${img_number[$img_pick]}
    declare url=${img_dick[$img_pick]}
  else
    echo "输入错误"
    exit
  fi
  echo "{\"registry-mirrors\": [\"${url}\"]}" > "/etc/docker/daemon.json"
  systemctl restart docker 2>> /dev/null|| echo "docker 重启失败"&&exit
  echo "换源成功"

  ;;
esac