#!/bin/bash

declare path="$1"
declare cron="$2"
declare web_path
declare local_pick
declare baidu_pick
declare aliyun_pick
declare cron
declare ignore=1


if [[ -f "${path}/backup.sh" ]];then
  echo "该路径文件已经存在"
fi

read -p "请输入数据目录,默认 /var/www ：" web_path
if [[ -z ${web_path} ]];then
  web_path='/var/www'
fi

for item in "$web_path"/* ; do
    [[ $ignore -eq 1 ]] && echo "当前脚本会备份的目录如下" && ignore=
    declare item_name=$(basename "$item")
    echo "${item_name}"
done

echo "请输入需要屏蔽的目录用逗号隔开"
read -p "请输入：" ignore


read -p "是否备份到本地，默认 关闭 ，输入 y 开启：" local_pick
read -p "是否备份到百度网盘，默认 开启 ，输入 n 关闭：" baidu_pick
read -p "是否备份到阿里云盘 默认 开启 ， 输入 n 关闭：" aliyun_pick

if [[ ! $local_pick =~ [Yy] && $baidu_pick =~ [Nn] && $aliyun_pick =~ [Nn] ]];then
  echo "没有选择备份的选项"
  exit
fi

if [[ $local_pick =~ [Yy] ]];then
  declare loacl_path
  read -p "请输入本地备份路径,默认 /var/webbackup ：" loacl_path
  if [[ -z $loacl_path ]];then
    loacl_path='/var/webbackup'
  fi
  if [[ -d $loacl_path ]];then
    mkdir -p "$loacl_path"
  fi
fi

if [[ ! $baidu_pick =~ [Nn] ]];then
  if [[ -f "/usr/bin/apt-get" ]];then
     sudo apt-get install python3-venv -y
  elif [[ -f "/usr/bin/apt" ]];then
     sudo apt-get install python3-venv -y
  else
     echo "无法自动安装 python3-venv 请手动安装"
     exit
  fi
  python3 -m venv "${path}/venv"
  source "${path}/venv/bin/activate"
  pip install bypy
  pip install requests
  echo "1.将提示中的链接粘贴到浏览器中登录"
  echo "2.输入账号密码登录后授权，获取授权码"
  echo "3.将授权码粘贴回终端并按回车"
  bypy info
fi


if [[ ! $aliyun_pick =~ [Nn] ]];then
  if [[ ! -d "${path}/aliyunpan" ]];then
    wget -P "${path}" https://github.com/tickstep/aliyunpan/releases/download/v0.3.2/aliyunpan-v0.3.2-linux-amd64.zip -O "${path}/aliyunpan.zip"
    unzip "${path}/aliyunpan.zip" -d "${path}"
    rm "${path}/aliyunpan.zip"
    mv "${path}/$(ls "${path}" | grep "aliyunpan")" "${path}/aliyunpan"
  fi
  if [[ "$( ${path}/aliyunpan/aliyunpan who)" == "未登录账号" ]];then
    ${path}/aliyunpan/aliyunpan login
  fi
fi

cat > "${path}/backup.sh" << EOF
#!/bin/bash
declare date_time=\$(date +"%Y_%m_%d") # 日期格式
declare year=\$(date +"%Y") #年份
declare ignore=$ignore
source \"${path}/venv/bin/activate\"

for item in "$web_path"/*; do
    declare item_name=\$(basename "\$item")
    if [[ "\$ignore" =~ "\$item" ]];then
          continue
    fi
    cd "\$item" || exit
    tar -czf "\${item_name}_\${date_time}.tar.gz" \$(ls)
    bypy upload "\${item_name}_\${date_time}.tar.gz" "/\${item_name}/"
    ${path}/aliyunpan/aliyunpan upload "\${item_name}_\${date_time}.tar.gz" "/网站/\${item_name}/\${year}/"
    cp "\${item_name}_\${date_time}.tar.gz" "${local_pick}/\${year}/"
    rm "\${item_name}_\${date_time}.tar.gz"
done
EOF
chmod +x "$path/backup.sh"

declare cron_job="${cron} ${path}/backup.sh"
(crontab -l 2>/dev/null | grep -v "backup.sh") | sudo crontab -

sudo systemctl restart cron 2>> /dev/null || echo "自动任务重启失败"

if [[ $local_pick == [Yy] ]];then
  echo "本地备份路径：${web_path}/年份/目录名称"
else
  sed -i '/cp.*/d' "${path}/backup.sh"
fi

if [[ $baidu_pick == [Nn] ]];then
  sed -i '/bypy.*/d' "${path}/backup.sh"
  sed -i '/source.*/d' "${path}/backup.sh"
else
  echo "百度网盘备份路径：我的应用数据/bypy/目录名称"
fi

if [[ $baidu_pick == [Nn] ]];then
  sed -i '/.*aliyunpan.*/d' "/var/script/backup.sh"
else
  echo "阿里云盘备份路径：网盘/目录名称/日期"
fi