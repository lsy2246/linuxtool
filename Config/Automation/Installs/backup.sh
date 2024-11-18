#!/bin/bash

declare backup_path="$1"
declare data_directory
declare local_backup_choice
declare baidu_backup_choice
declare aliyun_backup_choice
declare ignore_flag=1

read -p "请输入数据目录，默认 /var/www ：" data_directory
if [[ -z ${data_directory} ]];then
  data_directory='/var/www'
fi

for item in "$data_directory"/* ; do
    [[ $ignore_flag -eq 1 ]] && echo "当前脚本会备份的目录如下" && ignore_flag=
    declare item_name=$(basename "$item")
    echo "${item_name}"
done

echo "请输入需要屏蔽的目录，用空格隔开"
read -p "请输入：" ignore

read -p "是否备份到本地，默认关闭，输入 y 开启：" local_backup_choice
read -p "是否备份到百度网盘，默认开启，输入 n 关闭：" baidu_backup_choice
read -p "是否备份到阿里云盘，默认开启，输入 n 关闭：" aliyun_backup_choice

if [[ ! $local_backup_choice =~ [Yy] && $baidu_backup_choice =~ [Nn] && $aliyun_backup_choice =~ [Nn] ]];then
  echo "没有选择备份的选项"
  exit
fi

if [[ $local_backup_choice =~ [Yy] ]];then
  declare local_backup_path
  read -p "请输入本地备份路径，默认 /var/webbackup ：" local_backup_path
  if [[ -z $local_backup_path ]];then
    local_backup_path='/var/webbackup'
  fi
  if [[ -d $local_backup_path ]];then
    mkdir -p "$local_backup_path"
  fi
fi

if [[ ! $baidu_backup_choice =~ [Nn] ]];then
  if [[ -f "/usr/bin/apt-get" ]];then
     sudo apt-get install python3-venv -y
  elif [[ -f "/usr/bin/apt" ]];then
     sudo apt-get install python3-venv -y
  elif [[ -f "/usr/bin/pacman" ]];then
       sudo pacman -Sy python3-venv --noconfirm
  else
     echo "无法自动安装 python3-venv，请手动安装"
     exit
  fi
  python3 -m venv "${backup_path}/venv"
  source "${backup_path}/venv/bin/activate"
  pip install bypy
  pip install requests
  echo "1. 将提示中的链接粘贴到浏览器中登录"
  echo "2. 输入账号密码登录后授权，获取授权码"
  echo "3. 将授权码粘贴回终端并按回车"
  bypy info
fi

if [[ ! $aliyun_backup_choice =~ [Nn] ]];then
  if [[ ! -d "${backup_path}/aliyunpan" ]];then
    wget -P "${backup_path}" https://github.com/tickstep/aliyunpan/releases/download/v0.3.2/aliyunpan-v0.3.2-linux-amd64.zip -O "${backup_path}/aliyunpan.zip"
    unzip "${backup_path}/aliyunpan.zip" -d "${backup_path}"
    rm "${backup_path}/aliyunpan.zip"
    mv "${backup_path}/$(ls "${backup_path}" | grep "aliyunpan")" "${backup_path}/aliyunpan"
  fi
  if [[ "$( ${backup_path}/aliyunpan/aliyunpan who)" == "未登录账号" ]];then
    ${backup_path}/aliyunpan/aliyunpan login
  fi
fi

cat > "${backup_path}/backup.sh" << EOF
#!/bin/bash
declare date_time=\$(date +"%Y_%m_%d") # 日期格式
declare year=\$(date +"%Y") #年份
declare ignore="$ignore"
source "${backup_path}/venv/bin/activate"

for item in "$data_directory"/*; do
    declare item_name=\$(basename "\$item")
    if [[ "\$ignore" =~ \$item_name ]];then
          continue
    fi
    cd "\$item" || exit
    docker compose down
    tar -czf "\${item_name}_\${date_time}.tar.gz" \$(ls)
    docker compose up -d
    bypy upload "\${item_name}_\${date_time}.tar.gz" "/\${item_name}/"
    ${backup_path}/aliyunpan/aliyunpan upload "\${item_name}_\${date_time}.tar.gz" "/网站/\${item_name}/\${year}/"
    mkdir -p "${local_backup_path}/\${year}/\${item_name}" && cp "\${item_name}_\${date_time}.tar.gz" "${local_backup_path}/\${year}/\${item_name}"
    rm "\${item_name}_\${date_time}.tar.gz"
done
EOF

if [[ $local_backup_choice == [Yy] ]];then
  echo "本地备份路径：${data_directory}/年份/目录名称"
else
  sed -i '/mkdir.*/d' "${backup_path}/backup.sh"
fi

if [[ $baidu_backup_choice == [Nn] ]];then
  sed -i '/bypy.*/d' "${backup_path}/backup.sh"
  sed -i '/source.*/d' "${backup_path}/backup.sh"
else
  echo "百度网盘备份路径：我的应用数据/bypy/目录名称"
fi

if [[ $aliyun_backup_choice == [Nn] ]];then
  sed -i '/.*aliyunpan.*/d' "${backup_path}/backup.sh"
else
  echo "阿里云盘备份路径：网盘/目录名称/日期"
fi