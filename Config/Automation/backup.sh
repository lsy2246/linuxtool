#!/bin/bash

declare path=$1
declare web_path
declare local_pick
declare baidu_pick
declare aliyun_pick
declare -a cron_array=("分钟" "小时" "天数" "月份" "星期" )
declare cron

if [[ -f "${path}/update.sh" ]];then
  echo "该路径文件已经存在"
  exit
fi


read -p "请输入数据目录,默认 /var/www ：" web_path
if [[ -z ${web_path} ]];then
  web_path='/var/www'
fi
read -p "是否备份到本地，默认 关闭 ，输入 y 开启：" local_pick
read -p "是否备份到百度网盘，默认 开启 ，输入 n 关闭：" baidu_pick
read -p "是否备份到阿里云盘 默认 开启 ， 输入 n 关闭" aliyun_pick

if [[ ! $local_pick =~ [Yy] && $baidu_pick =~ [Nn] && $aliyun_pick =~ [Nn] ]];then
  echo "没有可备份的选项"
  exit
fi


if [[ $local_pick =~ Yy ]];then
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
  sudo apt-get install python3-venv -y
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
  cd "$path"
  wget https://github.com/tickstep/aliyunpan/releases/download/v0.3.2/aliyunpan-v0.3.2-linux-amd64.zip -O aliyunpan.zip
  unzip aliyunpan.zip
  rm aliyunpan.zip
  declare tmp_file=$( ls | grep aliyunpan )
  mv $tmp_file aliyunpan
  cd aliyunpan
   ./aliyunpan login
fi

echo
echo "执行日期"
echo "星号（*）：表示匹配任意值"
echo "逗号（,）：用于分隔多个值"
echo "斜线（/）：用于指定间隔值"
echo "连字符（-）：用于指定范围"

declare tmp_time
for i in "${cron_array[@]}";do
  read -p "${i}，默认为 * ：" tmp_time
  if [[ $tmp_time =~ ^[0-9]+$ || $tmp_time == '*' ]];then
    cron+="${tmp_time} "
  elif [[ -z ${tmp_time} ]];then
      cron+='* '
  else
    echo "输入错误"
    exit
  fi
done
if [[ "$cron" == '* * * * * ' ]];then
   read "该脚本会无时无刻执行，请重新输入"
   exit
fi



cat > "${path}/backup.sh" << EOF
#!/bin/bash
declare date_time=$(date +"%Y_%m_%d") # 日期格式
declare year=$(date +"%Y") #年份
cd "${path}/aliyunpan"
source "${path}/venv/bin/activate"

for item in "$web_path"/*; do
    item_name=$(basename "\$item")
    cd "\$item" || exit
    tar -czf "\${item_name}_\${date_time}.tar.gz" .
    bypy upload "\${item_name}_\${date_time}.tar.gz" "/\${item_name}/"
    ./aliyunpan upload "\${item_name}_\${date_time}.tar.gz" "/网站/\${item_name}/\${year}/"
    cp "\${item_name}_\${date_time}.tar.gz" "${web_path}/\${year}/"
    rm "\${item_name}_\${date_time}.tar.gz"
done
EOF
chmod +x "$path/backup.sh"

declare cron_job="${cron} ${path}/backup.sh"
(crontab -l 2>/dev/null | grep -Fxq "${path}/backup.sh") || (crontab -l 2>/dev/null; echo "$cron_job") | sudo crontab -

sudo systemctl restart cron 2>> /dev/null || echo "自动任务重启失败"

if [[ $local_pick == [Yn] ]];then
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