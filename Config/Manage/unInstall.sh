#!/bin/bash
declare path=$(cat /etc/profile | grep "tool=" | awk -F "=" '{print $2}' | tr -d "'")
path=$(dirname $path)
rm -rf $path
if [[ -e "${HOME}/.bashrc" ]];then
  sed -i '/alias tool.*/d' "${HOME}/.bashrc"
  source "${HOME}/.bashrc" &> /dev/null
fi

if [[ -e "${HOME}/.profile" ]];then
  sed -i '/alias tool.*/d' "${HOME}/.profile"
  source "${HOME}/.profile" &> /dev/null
fi

if [[ -e "${HOME}/.zshrc" ]];then
  sed -i '/alias tool.*/d' "${HOME}/.zshrc"
  source "${HOME}/.zshrc" &> /dev/null
fi

sed -i '/alias tool.*/d' "/etc/profile"
echo "脚本已经卸载完整,公众号 lsy22 可以获取一键安装脚本"
kill $PPID &> /dev/null