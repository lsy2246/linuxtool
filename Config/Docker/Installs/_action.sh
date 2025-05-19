#!/bin/bash
# 接收参数
local_path=$1
selected_script=$2

# 配置存储路径
declare storage_path
read -p "请输入软件存储位置，默认 /var/www/${selected_script} ：" storage_path
if [[ -z ${storage_path} ]]; then
  storage_path="/var/www/${selected_script}"
fi

# 检查并创建目录
if [[ ! -d "$storage_path" ]]; then
  mkdir -p "$storage_path" || {
    echo "目录创建失败"
    exit 1
  }
elif [[ ! -z "$(find "$storage_path" -mindepth 1 -print -quit)" ]]; then
  echo "该目录存有文件"
  read -p "是否继续？(y/n): " continue_choice
  if [[ ! $continue_choice =~ [Yy] ]]; then
    echo "安装已取消"
    exit
  fi
fi

# 生成随机端口
declare random_port=$(($RANDOM % 9000 + 1000))

while ss -tuln | grep $random_port &>/dev/null; do
  random_port=$(($RANDOM % 9000 + 1000))
done

# 配置访问端口
declare access_port
read -p "请输入访问端口，默认 $random_port ：" access_port

if [[ -z $access_port ]]; then
  access_port=$random_port
fi

# 检查端口是否被占用
if ss -tuln | grep $access_port &>/dev/null; then
  echo "端口已被占用"
  read -p "是否使用其他端口？(y/n): " port_choice
  if [[ $port_choice =~ [Yy] ]]; then
    read -p "请输入新的端口: " access_port
  else
    echo "安装已取消"
    exit
  fi
fi

# 执行原始安装脚本
bash "${local_path}/${selected_script}.sh" "$storage_path" "$access_port"
echo "${selected_script} 安装完成，访问端口 ${access_port}" 