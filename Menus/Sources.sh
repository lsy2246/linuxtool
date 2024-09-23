#!/bin/bash

declare version=$(cat /etc/os-release | grep VERSION_CODENAME | awk -F '=' '{print $2}')
declare system=$(cat /etc/os-release | grep "^ID" | awk -F '=' '{print $2}')
declare status=0

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
elif [[ ${pick} =~ [1-${#sources_dick[@]}] ]];then
        pick=${pcik_array[$pick]}
        declare url=${sources_dick[$pick]}
else
        echo "输入错误"
        exit
fi

case "$version" in
    'bookworm')
        cat > "/etc/apt/sources.list" << EOF
deb ${url}/debian/ bookworm main contrib non-free non-free-firmware
deb ${url}/debian/ bookworm-updates main contrib non-free non-free-firmware
deb ${url}/debian/ bookworm-backports main contrib non-free non-free-firmware
EOF
        apt update -y
        apt-get update -y
        status=1
    ;;
      'bullseye')
              cat > "/etc/apt/sources.list" << EOF
deb ${url}/debian/ bullseye main contrib non-free
deb ${url}/debian/ bullseye-updates main contrib non-free
deb ${url}/debian/ bullseye-backports main contrib non-free
EOF
              apt update -y
              apt-get update -y
              status=1
          ;;
esac

case "$system" in
    'arch')
        pacman -Sy pacman-key  --noconfirm
        sed -i '/^Server.*/d' "/etc/pacman.conf"
        echo "Server = ${url}/archlinuxcn/\$arch"
        pacman-key --lsign-key "farseerfc@archlinux.org"
        pacman -Syyu
        status=1
    ;;
  'ubuntu')
        cat > "/etc/apt/sources.list" << EOF
deb ${url}/ubuntu/ ${version} main restricted universe multiverse
deb ${url}/ubuntu/ ${version}-security main restricted universe multiverse
deb ${url}/ubuntu/ ${version}-updates main restricted universe multiverse
deb ${url}/ubuntu/ ${version}-backports main restricted universe multiverse
EOF
        apt update -y
        apt-get update -y
        status=1
    ;;
esac


if [[ $status == 0 ]]; then
    echo "暂不支持该系统一键换源"
    exit
fi


echo "换源成功"