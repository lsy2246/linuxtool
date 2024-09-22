declare pick
declare path_script=$1
echo "========Other========"
echo "1.开启BBR"
echo "2.更换系统语言"
echo "3.申请SSL证书"
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
      bash "${path_script}/Config/Other/Language.sh"
    ;;
  '3')
      bash "${path_script}/Config/Other/Acme.sh"
    ;;
esac