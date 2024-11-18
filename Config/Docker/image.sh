#!/bin/bash
echo "1. 查看当前运行中的镜像"
echo "2. 停止镜像"
echo "3. 删除未使用的镜像"

declare user_choice
read -p "请输入选项：" user_choice

case $user_choice in
'1')
  docker ps --format "{{.Names}}"
  ;;
'2')
  declare -a running_images=($(docker ps --format "{{.Names}}"))
  declare image_count=0
  for image in "${running_images[@]}" ; do
    image_count=$(( image_count+1 ))
    echo "${image_count}.${image}"
  done
  echo "要停止的镜像序号，多个镜像用空格隔开"
  read -p "请输入："  user_choice
  for i in $user_choice ; do
      if [[ $i =~ [1-$image_count] ]]; then
          echo "正在停止 ${running_images[$(( i -1 ))]}"
          docker stop "${running_images[$(( i -1 ))]}"
          echo "${running_images[$(( i -1 ))]} 已经停止"
      fi
  done
  ;;
'3')
  docker system prune -af
  echo "清理完成"
esac