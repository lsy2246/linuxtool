#!/bin/bash
declare tool_path=$(cat /etc/profile | grep "tool=" | awk -F "=" '{print $2}' | tr -d "'")
tool_path=$(dirname $tool_path)
rm -rf $tool_path

# 删除软链接
if [[ -L "/usr/bin/tool" ]]; then
  rm -f "/usr/bin/tool"
fi

# 从环境变量配置中删除工具路径
sed -i '/tool=.*/d' /etc/profile

echo "脚本已完整卸载，公众号 lsy22 可获取一键安装脚本"
kill $PPID &>/dev/null
