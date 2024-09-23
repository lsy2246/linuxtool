#!/bin/bash
declare path
echo "请输入脚本的安装位置"
read -p "默认 /var/script：" path
if [[ -z $path ]];then
    path="/var/script"
fi

mkdir -p "$path"
rm -rf "$path/linuxtoo"

wget https://g.lsy22.com/lsy/LinuxTool/archive/master.tar.gz -O "${path}/aa"
tar -zxf "$path/aa" -C $path
rm "$path/aa"
chmod +x "$path/linuxtool/Run.sh"

sed -i '/alias tool.*/d' "${HOME}/.bashrc"
echo "alias tool=$path/linuxtool/Run.sh" | cat >> "${HOME}/.bashrc"

source "${HOME}/.bashrc"