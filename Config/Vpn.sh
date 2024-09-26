#!/bin/bash
declare vpn_number=0
declare -a vpn_index
declare -A vpn_array
declare vpn_pick

vpn_array["v2ray"]='bash <(curl -s -L https://git.io/v2ray.sh)'
vpn_array["v2ray-agent"]='wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh'
vpn_array["x-ui"]='bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/x-ui/master/install.sh)'
vpn_array["V2bX"]='wget -N https://raw.githubusercontent.com/wyx2685/V2bX-script/master/install.sh && bash install.sh'

for i in "${!vpn_array[@]}";do
  vpn_number=$((vpn_number+1))
  vpn_index[${vpn_number}]=${i}
  echo "${vpn_number}.${i}"
done
read -p "请输入要选择的序号：" vpn_pick

if [[ $vpn_pick =~ [1-${#vpn_array[@]}] ]];then
  eval "${vpn_array[${vpn_index[$vpn_pick]}]}"
  echo "安装完成"
else
  echo "输入错误"
fi

