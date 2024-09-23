#!/bin/bash
declare path
echo "请输入脚本的安装位置"
read -p "默认 /var/script：" path
if [[ -z $path ]];then
    path="/var/script"
fi

mkdir -p "$path"
rm -rf "$path/linuxtoo"

wget https://g.lsy22.com/lsy/LinuxTool/archive/master.tar.gz -O "${path}/aa" &> /dev/null

if [[ -d "${path}/aa" ]];then
  echo "脚本下载失败"
  exit
fi
tar -zxf "$path/aa" -C $path &> /dev/null
rm "$path/aa"
chmod +x "$path/linuxtool/Run.sh" &> /dev/null

sed -i '/alias tool.*/d' "${HOME}/.bashrc"
echo "alias tool='$path/linuxtool/Run.sh'" | cat >> "${HOME}/.bashrc"

source "${HOME}/.bashrc"
export tool="$path/linuxtool/Run.sh"

echo "工具箱已经安装成功"
echo "位置：${path}/linuxtool"
echo "命令：tool"