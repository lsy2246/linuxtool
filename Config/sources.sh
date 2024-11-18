#!/bin/bash

declare os_version=$(cat /etc/os-release | grep VERSION_CODENAME | awk -F '=' '{print $2}')
declare os_id=$(cat /etc/os-release | grep "^ID" | awk -F '=' '{print $2}')
declare update_status=0

declare -A mirror_sources
mirror_sources['中国科技技术大学(默认)']='http://mirrors.ustc.edu.cn'
mirror_sources['清华大学']='https://mirrors.tuna.tsinghua.edu.cn'
mirror_sources['阿里云']='https://mirrors.aliyun.com'
mirror_sources['网易云']='https://mirrors.163.com'

declare -a selected_sources
declare source_choice=0
echo "========$(basename $0 .sh)========"
for i in "${!mirror_sources[@]}";
do
  source_choice=$(( source_choice+1 ))
  selected_sources[$source_choice]=$i
  echo "${source_choice}.${i}"
done
read -p "请输入选择的源：" source_choice

if [[ -z $source_choice ]];then
        declare selected_url='http://mirrors.ustc.edu.cn'
elif [[ ${source_choice} =~ [1-${#mirror_sources[@]}] ]];then
        source_choice=${selected_sources[$source_choice]}
        declare selected_url=${mirror_sources[$source_choice]}
else
        echo "输入错误"
        exit
fi

case "$os_version" in
    'bookworm')
        cat > "/etc/apt/sources.list" << EOF
deb ${selected_url}/debian/ bookworm main contrib non-free non-free-firmware
deb ${selected_url}/debian/ bookworm-updates main contrib non-free non-free-firmware
deb ${selected_url}/debian/ bookworm-backports main contrib non-free non-free-firmware
EOF
        apt update -y
        apt-get update -y
        update_status=1
    ;;
      'bullseye')
              cat > "/etc/apt/sources.list" << EOF
deb ${selected_url}/debian/ bullseye main contrib non-free
deb ${selected_url}/debian/ bullseye-updates main contrib non-free
deb ${selected_url}/debian/ bullseye-backports main contrib non-free
EOF
              apt update -y
              apt-get update -y
              update_status=1
          ;;
esac

case "$os_id" in
    'arch')
        pacman -Sy pacman-key  --noconfirm
        sed -i '/^Server.*/d' "/etc/pacman.conf"
        echo "Server = ${selected_url}/archlinuxcn/\$arch"
        pacman-key --lsign-key "farseerfc@archlinux.org"
        pacman -Syyu
        update_status=1
    ;;
  'ubuntu')
        cat > "/etc/apt/sources.list" << EOF
deb ${selected_url}/ubuntu/ ${os_version} main restricted universe multiverse
deb ${selected_url}/ubuntu/ ${os_version}-security main restricted universe multiverse
deb ${selected_url}/ubuntu/ ${os_version}-updates main restricted universe multiverse
deb ${selected_url}/ubuntu/ ${os_version}-backports main restricted universe multiverse
EOF
        apt update -y
        apt-get update -y
        update_status=1
    ;;
esac

if [[ $update_status == 0 ]]; then
    echo "暂不支持该系统一键换源"
    exit
fi

echo "换源成功"