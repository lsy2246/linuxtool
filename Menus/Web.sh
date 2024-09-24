#!/bin/bash

declare path_script=$1
declare file_name=$(basename $0 .sh)

declare print_array
declare print_number=0
declare pick

echo "========Web========"
for i in "${path_script}/Config/${file_name}"/*;do
    print_number=$((print_number + 1))
    print_array[$print_number]=$(awk -F '.' '{print $1}' <<< "$(basename $i)")
    echo "${print_number}.${print_array[$print_number]}"
done
echo "========Web========"
read -p "请输入要使用的功能：" pick

if [[ "${pick}" =~ [1-${#print_array[*]}] ]];then
  bash "${path_script}/Config/${file_name}/${print_array[${pick}]}.sh"
fi