#!/bin/bash
declare path
echo "请输入脚本的安装位置"
read -p "默认 /var/script：" path
if [[ -z $path ]];then
    path="/var/script"
fi
echo "软件正在安装中"

mkdir -p "$path"
rm -rf "$path/linuxtool"

wget https://g.lsy22.com/lsy/linuxtool/archive/master.tar.gz -O "${path}/aa" &> /dev/null

if [[ -d "${path}/aa" ]];then
  echo "脚本下载失败"
  exit
fi
tar -zxf "$path/aa" -C $path &> /dev/null
rm "$path/aa"
chmod +x "$path/linuxtool/Run.sh" &> /dev/null

if [[ -e "${HOME}/.bashrc" ]];then
  sed -i '/alias tool.*/d' "${HOME}/.bashrc"
  echo "alias tool='$path/linuxtool/Run.sh'" | cat >> "${HOME}/.bashrc"
  source "${HOME}/.bashrc" &> /dev/null
fi

if [[ -e "${HOME}/.profile" ]];then
  sed -i '/alias tool.*/d' "${HOME}/.profile"
  echo "alias tool='$path/linuxtool/Run.sh'" | cat >> "${HOME}/.profile"
  source "${HOME}/.profile" &> /dev/null
fi

if [[ -e "${HOME}/.zshrc" ]];then
  sed -i '/alias tool.*/d' "${HOME}/.zshrc"
  echo "alias tool='$path/linuxtool/Run.sh'" | cat >> "${HOME}/.zshrc"
  source "${HOME}/.zshrc" &> /dev/null
fi
alias tool="$path/linuxtool/Run.sh"

echo "工具箱已经安装成功"
echo "位置：${path}/linuxtool"
echo "命令：tool"