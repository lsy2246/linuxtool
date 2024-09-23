#!/bin/bash
declare pick
declare server
echo "请选择下载服务器"
echo "1.国内服务器"
echo "2.国外服务器(默认)"
read -p "请输入：" pick
if [[ $pick == '1' ]];then
  server="https://jihulab.com/bin456789/reinstall/-/raw/main/reinstall.sh"
else
  server="https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh"
fi

declare -A imags_dick
declare -a imags_arr
declare imags_number=0
imags_dick['arch']=""
imags_dick['kali']=""
imags_dick['debian']="8 9 10 11 12"
imags_dick['Ubuntu']="16.04 18.04 20.04 22.04 24.04"

for i in "${!imags_dick[@]}" ; do
    imags_number=$(( imags_number+1 ))
    imags_arr[$imags_number]=$i
    echo "${imags_number}.${i}"
done

read -p "请选择需要安装的镜像序号：" pick

if [[ $pick =~ [1-"${#imags_dick[@]}"\ ] ]];then
  declare img=${imags_arr[$pick]}
  declare version=''
  declare -a version_arr
  declare version_number=0
  if [[ ! -z ${imags_dick[$img]} ]];then
    echo "请输入要安装的版本（默认最新）"
    for i in ${imags_dick[$img]} ; do
      version_number=$(( version_number+1 ))
      version_arr[$version_number]=$i
      echo "${version_number}.${i}"
    done
    read -p "请输入：" pick
    if [ -z $pick ]; then
      version=$version_arr[$version_number]
    elif [[ $pick =~ [1-$version_number] ]];then
      version=$version_arr[$pick]
    fi
  echo "bash <(curl -Ls ${server}) ${img} ${version}"
  fi
else
  echo "选择错误"
fi