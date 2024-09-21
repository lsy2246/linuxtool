declare path="$1"
declare cron="$2"

if [[ -f "${path}/update.sh" ]];then
  echo "该路径文件已经存在"
fi

echo '#!/bin/bash' > "${path}/update.sh"

if [[ -f "/usr/bin/apt" ]];then
  echo 'sudo apt update -y' >> "${path}/update.sh"
  echo 'sudo apt-get dist-upgrad -y' >> "${path}/update.sh"
elif [[ -f "/usr/bin/apt-get" ]];then
    echo 'sudo apt-get update -y' >> "${path}/update.sh"
    echo 'sudo apt dist-upgrade -y' >> "${path}/update.sh"
else
  rm "${path}/update.sh"
  echo "暂不支持该系统配置自动更新软件"
  exit
fi

chmod +x "${path}/update.sh"

declare cron_job="${cron} ${path}/update.sh"
(crontab -l 2>/dev/null | grep -v "update.sh") | sudo crontab -
(crontab -l 2>/dev/null; echo "$cron_job") | sudo crontab -

sudo systemctl restart cron 2>> /dev/null || echo "自动任务重启失败"