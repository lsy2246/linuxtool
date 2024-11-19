#!/bin/bash

echo "1. 查看已安装的脚本"
echo "2. 删除脚本"

read -p "请输入您的选择：" user_choice

script_directory="/var/script"
read -p "请输入脚本安装目录，默认是 ${script_directory}：" input_directory

if [[ -n $input_directory ]]; then
    script_directory="$input_directory"
fi

if [[ ! -d $script_directory ]]; then
    echo "该目录不存在"
    exit 1
fi

function list_scripts() {
    local installed_scripts=()
    local script_count=0

    for script in "$script_directory"/*; do
        if [[ ! -e $script ]]; then
            echo "该目录没有脚本"
            return
        fi
        local script_name=$(basename "$script" | awk -F '.' '{print $1}')
        if [[ $script_name == "linuxtool" ]]; then
            continue
        fi
        script_count=$((script_count + 1))
        echo "${script_count}.${script_name}"
        installed_scripts+=("$script_name")
    done

    if [[ ${#installed_scripts[@]} -eq 0 ]]; then
        echo "该目录没有脚本"
        return
    fi

    echo "${installed_scripts[@]}"
}

case $user_choice in
    '1')
        list_scripts
        ;;
    '2')
        installed_scripts=($(list_scripts))
        read -p "请输入要删除的序号（多个用空格隔开）：" script_indices

        for index in $script_indices; do
            if [[ $index =~ ^[1-9][0-9]*$ ]] && [ $index -le ${#installed_scripts[@]} ]; then
                local script_to_delete=${installed_scripts[$((index - 1))]}
                echo "开始删除 ${script_to_delete}"
                (crontab -l 2>/dev/null | grep -v "$script_to_delete") | crontab - && echo "已删除脚本的自动任务"
                rm -rf "$script_directory/$script_to_delete" &>/dev/null
                echo "删除完成"
            else
                echo "无效的序号: $index"
            fi
        done
        ;;
    *)
        echo "无效的选择"
        exit 1
        ;;
esac
