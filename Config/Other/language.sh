#!/bin/bash
declare lang
echo "========$(basename $0 .sh)========"
echo "1.中文"
echo "2.英文"
read -p "请输入：" lang
if [[ -f "/usr/bin/apt-get" ]];then
  apt-get update -y
  apt-get install -y locales
  apt-get install -y language-pack-zh-hans
elif [[ -f "/usr/bin/apt" ]];then
  apt update -y
  apt install -y locales
  apt install -y language-pack-zh-hans
else
  echo "暂不支持该系统一键更换语言"
  exit
fi
sed -i '/^#/! s/^/# /' /etc/locale.gen
if ! grep LC_ALL /etc/default/locale &> /dev/null; then
    echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
fi
case $lang in
'1')
  sed -i 's/.*zh_CN.UTF-8.*/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
  sed -i "s/^LANG.*/LANG=zh_CN.UTF-8/g" /etc/default/locale
  sed -i "s/^LC_ALL.*/LC_ALL=zh_CN.UTF-8/g" /etc/default/locale
  ;;
'2')
  sed -i 's/.*en_US.UTF-8.*/en_US.UTF-8 UTF-8/g' /etc/locale.gen
  sed -i "s/^LANG.*/LANG=en_US.UTF-8/g" /etc/default/locale
  sed -i "s/^LC_ALL.*/LC_ALL=en_US.UTF-8/g" /etc/default/locale
  ;;
esac
locale-gen
update-locale
source /etc/default/locale
echo "语言更换成功"