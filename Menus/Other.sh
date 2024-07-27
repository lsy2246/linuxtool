declare pick
echo "========Other========"
echo "1.开启BBR"
echo "2.更换系统语言"
echo "输入其他任意返回主页"
echo "========Other========"
read -p "请输入：" pick

case "$pick" in
  '1')
    declare version=$(uname -r | awk -F "."  '{print $1}')
    if ! [[ $version -ge 5 ]];then
      echo "系统内核版本过低"
      exit
    fi
    grep -q "net.core.default_qdisc=fq" "/etc/sysctl.conf" || echo 'net.core.default_qdisc=fq' | sudo tee -a "/etc/sysctl.conf"
    grep -q "net.ipv4.tcp_congestion_control=bbr" "/etc/sysctl.conf" || echo 'net.ipv4.tcp_congestion_control=bbr' | sudo tee -a "/etc/sysctl.conf"
    sudo sysctl -p || echo "bbr 开启失败"
    sysctl net.ipv4.tcp_available_congestion_control | grep bbr && echo "bbr 开启成功"
  ;;
  '2')
    declare lang
    echo "1.中文"
    echo "2.英文"
    read -p "请输入：" lang
    if [[ -f "/usr/bin/apt-get" ]];then
      sudo apt-get install -y locales
      sudo apt-get install -y language-pack-zh-hans
    elif [[ -f "/usr/bin/apt" ]];then
      sudo apt install -y locales
      sudo apt install -y language-pack-zh-hans
    else
      echo "暂不支持该系统一键更换语言"
      exit
    fi
    sudo sed -i '/^#/! s/^/# /' /etc/locale.gen
    if ! grep LC_ALL /etc/default/locale &> /dev/null; then
        echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
    fi
    case $lang in
    '1')
      sudo sed -i 's/.*zh_CN.UTF-8.*/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
      sudo sed -i "s/^LANG.*/LANG=zh_CN.UTF-8/g" /etc/default/locale
      sudo sed -i "s/^LC_ALL.*/LC_ALL=zh_CN.UTF-8/g" /etc/default/locale
      ;;
    '2')
      sudo sed -i 's/.*en_US.UTF-8.*/en_US.UTF-8 UTF-8/g' /etc/locale.gen
      sudo sed -i "s/^LANG.*/LANG=en_US.UTF-8/g" /etc/default/locale
      sudo sed -i "s/^LC_ALL.*/LC_ALL=en_US.UTF-8/g" /etc/default/locale
      ;;
    esac
    sudo locale-gen
    update-locale
    source /etc/default/locale
    echo "英文语言更换成功"
esac