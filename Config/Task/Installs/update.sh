declare update_path="$1"

echo '#!/bin/bash' > "${update_path}/update.sh"

if [[ -f "/usr/bin/apt" ]];then
  echo 'apt update -y' >> "${update_path}/update.sh"
  echo 'apt-get dist-upgrade -y' >> "${update_path}/update.sh"
elif [[ -f "/usr/bin/apt-get" ]];then
    echo 'apt-get update -y' >> "${update_path}/update.sh"
    echo 'apt dist-upgrade -y' >> "${update_path}/update.sh"
elif [[ -f "/usr/bin/pacman" ]];then
     pacman -Syu --noconfirm
else
  rm "${update_path}/update.sh"
  echo "暂不支持该系统的自动更新配置"
  exit
fi
