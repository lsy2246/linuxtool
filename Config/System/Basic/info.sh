#!/bin/bash
declare cpu_info=$(cat /proc/cpuinfo)
declare cpu_moudle=$(echo "$cpu_info" | grep 'model name' | awk -F ': ' '{print $2}' | head -n 1)
echo "CPU 型号    ：$cpu_moudle"
declare cpu_cores=$(echo "$cpu_info" | grep 'cpu cores' | awk -F ': ' '{print $2}' | head -n 1)
echo "CPU 核心数  ：$cpu_cores"
declare cpu_mhz=$(echo "$cpu_info"| grep 'cpu MHz' | awk -F ': ' '{print $2}' | head -n 1)
echo "CPU 频率    ：$cpu_mhz"
declare cpu_cache=$(echo "$cpu_info"| grep 'cache size' | awk -F ': ' '{print $2}' | head -n 1)
echo "CPU 缓存    ：$cpu_cache"
declare swap=$(free -m | awk '/Swap/ {sum += $2} END {print sum / 1024 " GB"}')
echo "SWAP        ：$swap"
declare disk=$(lsblk -b -d -o SIZE,NAME | grep -vE "loop|ram" | awk '{sum += $1} END {print sum / 1024 /1024 / 1024 " GB"}')
echo "硬盘空间    ：$disk"
declare uptime_time=$(awk '{printf("%d天 %d小时 %d分钟\n", $1/86400, ($1%86400)/3600, ($1%3600)/60)}' /proc/uptime)
echo "系统在线时间：$uptime_time "
declare version=$(cat /etc/os-release | grep -E '^ID=' | awk -F= '{print $2}')
echo "系 统       ：$version"
declare kernel=$(cat /proc/version | awk '{print $3}')
echo "内 核       ：$kernel"
declare tcp_mode=$(sysctl -a | grep tcp_congestion_control | awk -F ' = ' '{print $2}')
echo "TCP加速方式 ：$tcp_mode"
declare systemd_detect_virt=$(systemd-detect-virt)
echo "虚拟化框架  ：$systemd_detect_virt"
declare ip_info=$(curl -s https://ip.lsy22.com/)
declare ip_v4=$(echo $ip_info | grep -oP '"ipv4":\s*"\K[^"]+')
echo "IPV4 位置   ：$ip_v4"
declare ip_v6=$(echo $ip_info | grep -oP '"ipv6":\s*"\K[^"]+')
echo "IPV6 位置   ：$ip_v6"
echo "CPU 测试中"
echo "内存测试中"
echo "以下为ipv4测试"
echo "以下为ipv6测试"
echo "以下为速度测试"
