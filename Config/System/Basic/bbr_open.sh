#!/bin/bash
declare kernel_version=$(uname -r | awk -F "."  '{print $1}')
if ! [[ $kernel_version -ge 5 ]];then
  echo "系统内核版本过低"
  exit
fi
grep -q "net.core.default_qdisc=fq" "/etc/sysctl.conf" || echo 'net.core.default_qdisc=fq' | tee -a "/etc/sysctl.conf"
grep -q "net.ipv4.tcp_congestion_control=bbr" "/etc/sysctl.conf" || echo 'net.ipv4.tcp_congestion_control=bbr' | tee -a "/etc/sysctl.conf"
sysctl -p || echo "BBR 开启失败"
sysctl net.ipv4.tcp_available_congestion_control | grep bbr && echo "BBR 开启成功"