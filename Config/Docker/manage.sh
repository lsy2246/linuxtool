#!/bin/bash
echo "1. 查看已安装的站点"
echo "2. 删除软件"

declare user_choice
read -p "请输入：" user_choice

declare site_path="/var/www"
echo "请输入站点安装地址，默认 ${site_path}"
read -p "请输入：" site_path

if [[ -z $site_path ]]; then
    site_path="/var/www"
elif ! [[ -d $site_path ]]; then
    echo "该地址不存在目录"
    exit 1
fi

function list_sites() {
    local site_number=0
    for site in "$site_path"/* ; do
        if [[ ! -d $site ]]; then
            echo "该地址不存在站点"
            return
        fi
        site_number=$(( site_number + 1 ))
        site_name=$(awk -F '.' '{print $1}' <<< "$(basename "$site")")
        echo "${site_number}.${site_name}"
        site_array[$site_number]=$site_name
    done
}

case $user_choice in
'1')
    list_sites
    ;;
'2')
    declare -a site_array
    list_sites
    read -p "请输入要删除的序号，多个用空格隔开：" selected_sites
    for i in $selected_sites ; do
        if [[ $i =~ ^[1-9][0-9]*$ ]] && [ "$i" -le "${#site_array[@]}" ]; then
            echo "开始删除 ${site_array[$i]}"
            cd "$site_path/${site_array[$i]}" || exit
            docker compose down &> /dev/null && echo "站点已停止运行"
            rm -rf "$site_path/${site_array[$i]}" &> /dev/null
            echo "删除完成"
        fi
    done
    echo "删除完成"
    ;;
esac