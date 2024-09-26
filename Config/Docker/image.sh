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
  declare -a deocker_arr=($(docker ps --format "{{.Names}}"))
  declare deocker_number=0
  for i in "${!docker_arr[@]}" ; do
    deocker_number=$(( deocker_number+1 ))
    echo "${deocker_number}.${i}"
  done
  echo "要删除的镜像序号,多个镜像用 空格 隔开"
  read -p "请输入："  pick
  for i in $pick ; do
      if [[ $i =~ [1-$deocker_number] ]]; then
          docker rmi "${deocker_arr[$i]}"
      fi
  done
  ;;
'3')
  docker system prune -af
  echo "清理完成"
esac