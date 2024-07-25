#!/bin/bash

declare pick
echo "========Automation========"
echo "1.自动备份"
echo "2.自动更新软件"
echo "3.自动Docker compose应用"
echo "4.自动更新ssh证书"
echo "输入其他任意返回主页"
echo "========Automation========"
read -p "请输入：" pick

if [[ ${pick} -lt 1 || ${pick} -gt 4 ]];then
  exit
fi

read -p "请输入脚本存放路径(默认：/var/script)：" path

if [[ -z $path ]];then
  path='/var/script'
fi
mkdir -p "$path"


case $pick in
    '1')
      bash Config/Automation/backup.sh "$path"
      ;;
      '2')
      bash Config/Automation/update.sh "$path"
      ;;
      '3')
      if ! command -v docker &> /dev/null; then
          echo "docker未安装"
          exit
      fi
      if [[ -f "${path}/up-docker_compose.sh" ]];then
        echo "该路径文件已经存在"
        exit
      fi
      declare web_path
      read -p "请输入数据目录,默认 /var/www ：" web_path
      if [[ -z ${web_path} ]];then
        web_path='/var/www'
      fi
      cat > "${path}/up-docker_compose.sh" << EOF
#!/bin/bash
docker_path="${web_path}"
for dir in "web_path"/*/; do
        cd "\$dir" || exit
        sudo docker compose pull
        sudo docker compose up -d
done
EOF
      chmod +x "${path}/up-docker_compose.sh"
      sudo systemctl restart cron 2>> /dev/null || echo "自动任务重启失败"
      ;;
    '4')
      echo "国内忘写了"
esac
echo "配置完成"