#!/bin/bash
echo "1.查看已经成功申请证书的域名"

declare user_choice
read -p "请输入选择：" user_choice

case $user_choice in
'1')
  declare certificate_name
  declare certificate_count=0
  declare -a certificate_array

  for i in "${HOME}/.acme.sh"/* ; do
      certificate_name=$(basename $i )
      if ! echo "$certificate_name" | grep -q "_ecc" ; then
        continue
      fi
      certificate_name=$(echo $certificate_name | sed "s/_ecc//g" )
      certificate_count=$(( certificate_count+1 ))
      certificate_array[$certificate_count]=$certificate_name
      echo "${certificate_count}.${certificate_name}"
  done
  if [ ${#certificate_array[@]} == 0 ]; then
      echo "暂时没有安装证书"
      exit
  fi
  read -p "请输入要查看证书详细信息的序号：" user_choice
  if [[ $user_choice =~ [1-${#certificate_array[@]}] ]]; then
      bash "${HOME}/.acme.sh/acme.sh -info -d ${certificate_array[$user_choice]}"
  else
    echo "选择错误"
  fi
  ;;
esac