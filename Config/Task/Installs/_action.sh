#!/bin/bash
# 接收参数
local_path=$1
selected_script=$2

# 脚本路径配置
read -p "请输入脚本存放路径（默认：/var/script）：" script_path

if [[ -z $script_path ]];then
  script_path='/var/script'
fi
mkdir -p "$script_path"

# 定时任务配置说明
echo "执行日期"
echo "星号（*）：表示匹配任意值"
echo "逗号（,）：用于分隔多个值"
echo "斜线（/）：用于指定间隔值"
echo "连字符（-）：用于指定范围"

# 配置cron表达式
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

# 验证cron表达式
if [[ "$cron_expression" == '* * * * * ' ]];then
   read -p "该脚本会无时无刻执行，请重新输入" 
   exit
fi

# 检查脚本是否存在
if [[ -f "${script_path}/${selected_script}.sh" ]];then
  echo "该路径文件已经存在"
  read -p "是否覆盖？(y/n): " overwrite
  if [[ ! $overwrite =~ [Yy] ]]; then
    echo "已取消操作"
    exit
  fi
fi

# 执行原始脚本
bash "${local_path}/${selected_script}.sh" "$script_path"

# 设置脚本权限
chmod +x "${script_path}/${selected_script}.sh" && echo "脚本执行权限添加成功" || echo "脚本执行权限添加失败"

# 配置定时任务
declare cron_job="${cron_expression} ${script_path}/${selected_script}.sh"
(crontab -l 2>/dev/null | grep -v "${selected_script}.sh") | crontab -
(crontab -l 2>/dev/null; echo "$cron_job") | crontab -

# 重启cron服务
systemctl restart cron 2>> /dev/null && echo "自动任务配置成功"  || echo "自动任务重启失败"

echo "配置完成"