#!/bin/bash
declare local_path=$1
declare user_choice
declare selected_file
echo "========$(basename $0 .sh)========"
declare file_count=0
declare -a file_array
for file in "${local_path}"/*;do
    selected_file=$(awk -F '.' '{print $1}' <<< "$(basename $file)")
    if [[ $selected_file == "test" || $selected_file == "menu" ]]; then
      continue
    fi
    file_count=$((file_count + 1))
    file_array[$file_count]=$selected_file
    echo "${file_count}.${selected_file}"
done
echo "输入其他任意值返回主页"
read -p "请输入：" user_choice

if [[ ! ${user_choice} =~ [1-$file_count] ]];then
  exit
fi

read -p "请输入脚本存放路径（默认：/var/script）：" script_path

if [[ -z $script_path ]];then
  script_path='/var/script'
fi
mkdir -p "$script_path"

echo "执行日期"
echo "星号（*）：表示匹配任意值"
echo "逗号（,）：用于分隔多个值"
echo "斜线（/）：用于指定间隔值"
echo "连字符（-）：用于指定范围"

declare cron_expression
declare -a cron_fields=("分钟	0–59" "小时	0–23" "天数	1–31" "月份	1–12" "星期	0–7" )
for field in "${cron_fields[@]}";do
  read -p "${field}，默认为 * ：" tmp_time
  if [[ $tmp_time =~ ^[0-9]+$ || $tmp_time == '*' ]];then
    cron_expression+="${tmp_time} "
  elif [[ -z ${tmp_time} ]];then
      cron_expression+='* '
  else
    echo "输入错误"
    exit
  fi
done
if [[ "$cron_expression" == '* * * * * ' ]];then
   read -p "该脚本会无时无刻执行，请重新输入" 
   exit
fi

if [[ -f "${local_path}/${file_array[user_choice]}.sh" ]];then
  echo "该路径文件已经存在"
fi

bash "${local_path}/${file_array[user_choice]}.sh" "$script_path"

chmod +x "${script_path}/${file_array[user_choice]}.sh" && echo "脚本执行权限添加成功" || echo "脚本执行权限添加失败"
declare cron_job="${cron_expression} ${script_path}/${file_array[user_choice]}.sh"
(crontab -l 2>/dev/null | grep -v "${file_array[user_choice]}.sh") | crontab -
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -

systemctl restart cron 2>> /dev/null && echo "自动任务配置成功"  || echo "自动任务重启失败"

echo "配置完成"