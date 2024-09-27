#!/bin/bash
echo "1.查看已经成功申请证书的域名"

declare pick
read -p "请输入：" pick

case $pick in
'1')
  declare print_name
  declare print_number=0
  declare -a print_arr

  for i in "${HOME}/.acme.sh"/* ; do
      print_name=$(basename $i )
      if ! echo $print_name | grep _ecc ; then
        continue
      fi
      print_name=$(echo $print_name | sed "s/_ecc//g" )
      print_number=$(( print_number+1 ))
      print_arr[$print_number]=$print_name
      echo "${print_number}.${print_name}"
  done
  read -p "请选择要查看证书的详细信息" pick
  if [[ $pick =~ [1-${#print_arr[@]}] ]]; then
      bash "${HOME}/.acme.sh -info -d ${print_arr[$pick]}"
  else
    echo "选择错误"
  fi
  ;;
esac