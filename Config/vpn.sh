#!/bin/bash
declare vpn_count=0
declare -a vpn_options
declare -A vpn_commands
declare user_choice

vpn_commands["v2ray"]='bash <(curl -s -L https://git.io/v2ray.sh)'
vpn_commands["v2ray-agent"]='wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh'
vpn_commands["3-ui"]='bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)'
vpn_commands["V2bX"]='wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh'

for i in "${!vpn_commands[@]}";do
  vpn_count=$((vpn_count+1))
  vpn_options[${vpn_count}]=${i}
  echo "${vpn_count}.${i}"
done
read -p "请输入要选择的序号：" user_choice

if [[ $user_choice =~ [1-${#vpn_commands[@]}] ]];then
  eval "${vpn_commands[${vpn_options[$user_choice]}]}"
  echo "安装完成"
else
  echo "输入错误"
fi

