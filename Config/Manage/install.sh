#!/bin/bash
if [[ $UID != 0 ]]; then
  echo "请以root权限执行该脚本"
  exit
fi

if ! command -v git &>/dev/null; then
  if [[ -f "/usr/bin/apt-get" ]]; then
    apt-get update -y
    apt-get install git -y
  elif [[ -f "/usr/bin/apt" ]]; then
    apt update -y
    apt install git -y
  elif [[ -f "/usr/bin/pacman" ]]; then
    pacman -Syu --noconfirm
    pacman -Sy --noconfirm git
  else
    echo "git未安装"
    exit
  fi
fi

declare path
echo "请输入脚本的安装位置"
read -p "默认 /var/script：" path
if [[ -z $path ]]; then
  path="/var/script"
fi

mkdir -p "$path"
rm -rf "$path/linuxtool"

declare -A url_dick
declare -a url_arr
declare url_number=0
declare url_pick
declare url
echo "请选择脚本的下载地址"
url_dick['github(default)']='https://github.com/lsy2246/linuxtool.git'
url_dick['gitee']='https://gitee.com/lsy22/linuxtool.git'

for i in "${!url_dick[@]}"; do
  url_number=$((url_number + 1))
  url_arr[$url_number]=$i
  echo "${url_number}.${i}"
done

read -p "请输入：" url_pick

if [[ $url_pick =~ [1-${#url_dick[@]}] ]]; then
  url=${url_dick[${url_arr[$url_pick]}]}
else
  url='https://github.com/lsy2246/linuxtool.git'
fi

echo "正在下载脚本中"
git clone "$url" "$path/linuxtool" &>/dev/null

if ! [[ -d "${path}/linuxtool" ]]; then
  echo "脚本下载失败"
  exit
fi

chmod +x "$path/linuxtool/run.sh" &>/dev/null

# 创建软链接到 /usr/bin 目录
echo "正在创建软链接..."
ln -sf "$path/linuxtool/run.sh" "/usr/bin/tool"
chmod +x "/usr/bin/tool"

# 将工具路径写入环境变量配置
echo "tool='$path/linuxtool/run.sh'" >>/etc/profile

echo "工具箱已经安装成功"
echo "位置：${path}/linuxtool"
echo "命令：tool"

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  kill $PPID &>/dev/null
fi
