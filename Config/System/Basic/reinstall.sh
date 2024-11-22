#!/bin/bash
declare server_choice
declare download_server
echo "========$(basename $0 .sh)========"
echo "请选择下载服务器"
echo "1. 国内服务器"
echo "2. 国外服务器（默认）"
read -p "请输入：" server_choice
if [[ $server_choice == '1' ]];then
  download_server="https://jihulab.com/bin456789/reinstall/-/raw/main/reinstall.sh"
else
  download_server="https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh"
fi

declare -A image_options
declare -a image_list
declare image_count=0
image_options['arch']=""
image_options['kali']=""
image_options['debian']="8 9 10 11 12"
image_options['Ubuntu']="16.04 18.04 20.04 22.04 24.04"

for image in "${!image_options[@]}" ; do
    image_count=$(( image_count+1 ))
    image_list[$image_count]=$image
    echo "${image_count}.${image}"
done

read -p "请选择需要安装的镜像序号：" selected_image

if [[ $selected_image =~ [1-"${#image_options[@]}"\ ] ]];then
  declare selected_image_name=${image_list[$selected_image]}
  declare selected_version=''
  declare -a version_list
  declare version_count=0
  if [[ ! -z ${image_options[$selected_image_name]} ]];then
    echo "请输入要安装的版本（默认最新）"
    for version in ${image_options[$selected_image_name]} ; do
      version_count=$(( version_count+1 ))
      version_list[$version_count]=$version
      echo "${version_count}.${version}"
    done
    read -p "请输入：" selected_version
    if [ -z $selected_version ]; then
      selected_version=${version_list[$version_count]}
    elif [[ $selected_version =~ [1-$version_count] ]];then
      selected_version=${version_list[$selected_version]}
    fi
  fi
  eval "bash <(curl -Ls ${download_server}) ${selected_image_name} ${selected_version}"
  echo "重启后开始重装系统"
  echo "用服务器厂家的 VNC 连接可以看到重装进度"
else
  echo "选择错误"
fi