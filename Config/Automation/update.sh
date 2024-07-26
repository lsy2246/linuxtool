declare version=$(cat /etc/os-release | grep '^ID' | awk -F '=' '{print $2}')
declare path=$1

if [[ -f "${path}/update.sh" ]];then
  echo "该路径文件已经存在"
  exit
fi

case "$version" in
    'debian')
        cat > "${path}/update.sh" << EOF
#!/bin/bash
sudo apt update
sudo apt-get update
sudo apt dist-upgrade
sudo apt-get dist-upgrade
EOF
        ;;
    *)
        echo "暂不支持该系统配置自动更新软件"
        exit
esac

chmod +x "${path}/update.sh"

declare cron_job="${cron} ${path}/update.sh"
(crontab -l 2>/dev/null | grep -v "update.sh") | sudo crontab -
(crontab -l 2>/dev/null; echo "$cron_job") | sudo crontab -

sudo systemctl restart cron 2>> /dev/null || echo "自动任务重启失败"