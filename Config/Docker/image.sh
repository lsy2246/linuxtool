#!/bin/bash
echo "1.查看当前运行中的镜像"
echo "2.停止镜像"
echo "3.删除没有使用的镜像"

declare pick
read -p "请输入：" pick

case $pick in
'1')
  docker ps --format "{{.Names}}"
  ;;
'2')
  declare -a docker_arr=($(docker ps --format "{{.Names}}"))
  declare docker_number=0
  for i in "${docker_arr[@]}" ; do
    docker_number=$(( docker_number+1 ))
    echo "${docker_number}.${i}"
  done
  echo "要停止的镜像序号,多个镜像用 空格 隔开"
  read -p "请输入："  pick
  for i in $pick ; do
      if [[ $i =~ [1-$docker_number] ]]; then
          docker stop "${docker_arr[$(( i -1 ))]}"
      fi
  done
  ;;
'3')
  docker system prune -af
  echo "清理完成"
esac