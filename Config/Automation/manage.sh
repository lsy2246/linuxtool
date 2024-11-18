#!/bin/bash

# 显示菜单
function show_menu() {
    echo "1. 查看已安装的脚本"
    echo "2. 删除脚本"
}

# 获取用户选择
function get_user_choice() {
    read -p "请输入您的选择：" user_choice
    echo $user_choice
}

# 获取脚本目录
function get_script_directory() {
    local default_directory="/var/script"
    read -p "请输入脚本安装目录（默认是 ${default_directory}）：" script_directory
    [[ -z $script_directory ]] && script_directory=$default_directory
    echo $script_directory
}

# 列出已安装的脚本
function list_installed_scripts() {
    local directory=$1
    declare -a scripts
    local count=0

    for script in "$directory"/* ; do
        if [[ $script == "${directory}/*" ]]; then
            echo "该目录没有脚本"
            return
        fi
        local script_name=$(awk -F '.' '{print $1}' <<< "$(basename $script)")
        if [[ $script_name == "linuxtool" ]]; then
            continue
        fi
        count=$(( count + 1 ))
        echo "${count}.${script_name}"
        scripts[$count]=$script_name
    done

    if [ ${#scripts[@]} == 0 ]; then
        echo "该目录没有脚本"
        return
    fi

    echo "${scripts[@]}"
}

# 删除脚本
function delete_scripts() {
    local scripts=("$@")
    read -p "请输入要删除的序号（多个用空格隔开）：" indices
    for i in $indices ; do
        if [[ $i =~ ^[1-9][0-9]*$ ]] && [ $i -le ${#scripts[@]} ]; then
            echo "开始删除 ${scripts[$i]}"
            (crontab -l 2>/dev/null | grep -v "${scripts[$i]}") | crontab - && echo "已删除脚本的自动任务"
            rm -rf "$script_directory/${scripts[$i]}" &> /dev/null
            echo "删除完成"
        fi
    done
}

# 主程序
show_menu
user_choice=$(get_user_choice)
script_directory=$(get_script_directory)

case $user_choice in
'1')
    installed_scripts=($(list_installed_scripts "$script_directory"))
    ;;
'2')
    installed_scripts=($(list_installed_scripts "$script_directory"))
    delete_scripts "${installed_scripts[@]}"
    ;;
esac