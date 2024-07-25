#!/bin/bash

declare version=$(cat /etc/os-release | grep VERSION_CODENAME | awk -F '=' '{print $2}')

case "$version" in
    'bookworm')
        ;;
    *)
        echo "暂不支持该系统一键换源"
        exit
esac

declare -A sources_dick
sources_dick['中国科技技术大学(默认)']='http://mirrors.ustc.edu.cn'
sources_dick['清华大学']='https://mirrors.tuna.tsinghua.edu.cn'
sources_dick['阿里云']='https://mirrors.aliyun.com'
sources_dick['网易云']='https://mirrors.163.com'

declare -a pcik_array
declare pick=0
echo "========Sources========"
for i in "${!sources_dick[@]}";
do
  pick=$(( pick+1 ))
  pcik_array[$pick]=$i
  echo "${pick}.${i}"
done
echo "========Sources========"
read -p "请输入：" pick


if [[ -z $pick ]];then
        declare url='http://mirrors.ustc.edu.cn'
elif [[ ${pick} -le 0 || ${pick} -gt  ${#sources_dick[*]} ]];then
          echo "输入错误"
          exit
else
        pick=${pcik_array[$pick]}
        declare url=${sources_dick[$pick]}
fi



case "$version" in
    'bookworm')
        cat > "/etc/apt/sources.list" << EOF
deb ${url}/debian/ bookworm main contrib non-free non-free-firmware
deb ${url}/debian/ bookworm-updates main contrib non-free non-free-firmware
deb ${url}/debian/ bookworm-backports main contrib non-free non-free-firmware
EOF
        sudo apt-get update
    ;;
    *)
        echo "暂不支持该系统配置自动更新软件"
        exit
esac

echo "换源成功"