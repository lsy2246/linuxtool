#!/bin/bash

declare version=$(cat /etc/os-release | grep VERSION_CODENAME | awk -F '=' '{print $2}')

case "$version" in
    'bookworm')
        ;;
    *)
        echo "暂不支持该系统一键换源"
        exit
esac


sources_array[1]='http://mirrors.ustc.edu.cn'
sources_array[2]='https://mirrors.tuna.tsinghua.edu.cn'
sources_array[3]='https://mirrors.aliyun.com'


declare pick
echo "========Sources========"
echo "1.中国科技技术大学"
echo "2.清华大学"
echo "3.阿里云"
echo "========Sources========"
read -p "请输入(默认1)：" pick

if [[ -z $pick ]];then
        pick=1
fi

echo $pick

if ! [[ ${pick} =~ [123] ]];then
        echo "输入错误"
        exit
fi

case "$version" in
    'bookworm')
        {
            echo "deb ${sources_array[$pick]}/debian/ bookworm main contrib non-free non-free-firmware"
            echo "deb ${sources_array[$pick]}/debian/ bookworm-updates main contrib non-free non-free-firmware"
            echo "deb ${sources_array[$pick]}/debian/ bookworm-backports main contrib non-free non-free-firmware"
        } > /etc/apt/sources.list
        sudo apt-get update
    ;;
esac