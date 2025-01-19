#!/bin/bash
declare -A info_dict
declare -a info_array

cpu_info=$(cat /proc/cpuinfo)
info_dict["CPU 型号"]=$(echo "$cpu_info" | grep -m1 -oP 'model name\s*:\s*\K.+')
info_dict["CPU 核心数"]=$(echo "$cpu_info" | grep -m1 -oP 'cpu cores\s*:\s*\K\d+')
info_dict["CPU 频率"]=$(echo "$cpu_info" | grep -m1 -oP 'cpu MHz\s*:\s*\K.+')
info_dict["CPU 缓存"]=$(echo "$cpu_info" | grep -m1 -oP 'cache size\s*:\s*\K.+')

info_dict["SWAP"]=$(free -m | awk '/Swap/ {printf "%.2f GB", $2/1024}')
info_dict["硬盘空间"]=$(lsblk -b -d -o SIZE,NAME | grep -vE "loop|ram" | awk '{sum += $1} END {printf "%.2f GB", sum/1024/1024/1024}')
info_dict["系统在线时间"]=$(awk '{printf("%d天 %d小时 %d分钟", $1/86400, ($1%86400)/3600, ($1%3600)/60)}' /proc/uptime)
info_dict["内核"]=$(uname -r)
info_dict["TCP加速方式"]=$(sysctl -n net.ipv4.tcp_congestion_control)
info_dict["虚拟化框架"]=$(systemd-detect-virt)

ip_info=$(curl -s https://ip.lsy22.com/)
info_dict["IPV4 位置"]=$(echo "$ip_info" | grep -oP '"ipv4":\s*"\K[^"]+')
info_dict["IPV6 位置"]=$(echo "$ip_info" | grep -oP '"ipv6":\s*"\K[^"]+')

info_array=(
    "CPU 型号" "CPU 核心数" "CPU 频率" "CPU 缓存"
    "SWAP" "硬盘空间" "系统在线时间" "内核" "TCP加速方式"
    "虚拟化框架" "IPV4 位置" "IPV6 位置"
)

max_length=$(printf "%s\n" "${info_array[@]}" | awk '{print length}' | sort -nr | head -1)

for title in "${info_array[@]}"; do
    printf "%-${max_length}s : %s\n" "$title" "${info_dict[$title]}"
done

echo -e "\n待办项目："
echo "CPU 测试中"
echo "内存测试中"
echo "IPV4测试中"
echo "IPV6测试中"
echo "速度测试中"