declare path="$1"

echo '#!/bin/bash' > "${path}/update.sh"

if [[ -f "/usr/bin/apt" ]];then
  echo 'sudo apt update -y' >> "${path}/update.sh"
  echo 'sudo apt-get dist-upgrad -y' >> "${path}/update.sh"
elif [[ -f "/usr/bin/apt-get" ]];then
    echo 'sudo apt-get update -y' >> "${path}/update.sh"
    echo 'sudo apt dist-upgrade -y' >> "${path}/update.sh"
elif [[ -f "/usr/bin/pacman" ]];then
     sudo pacman -Syu --noconfirm
else
  rm "${path}/update.sh"
  echo "暂不支持该系统配置自动更新软件"
  exit
fi
