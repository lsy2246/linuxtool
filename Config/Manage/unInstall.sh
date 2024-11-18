#!/bin/bash
declare tool_path=$(cat /etc/profile | grep "tool=" | awk -F "=" '{print $2}' | tr -d "'")
tool_path=$(dirname $tool_path)
rm -rf $tool_path

remove_alias() {
  local file="$1"
  if [[ -e "$file" ]]; then
    sed -i '/alias tool.*/d' "$file"
    source "$file" &> /dev/null
  fi
}

for file in "${HOME}/.bashrc" "${HOME}/.profile" "${HOME}/.zshrc" "/etc/profile"; do
  remove_alias "$file"
done



echo "脚本已完整卸载，公众号 lsy22 可获取一键安装脚本"
kill $PPID &> /dev/null