#!/bin/bash
declare tool_path=$(cat /etc/profile | grep "tool=" | awk -F "=" '{print $2}' | tr -d "'")
tool_path=$(dirname $tool_path)
rm -rf $tool_path
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
echo "脚本已完整卸载，公众号 lsy22 可获取一键安装脚本"
kill $PPID &> /dev/null