#!/bin/bash

declare install_str
declare version=$(cat /etc/os-release | grep -w 'ID' | awk -F '=' '{print $2}')
case "$version" in
    'debian')
    install_str='apt-get install'   
        
        ;;
    *)
        echo "暂不支持该系统一键安装常用软件"
        exit
esac

declare pick
declare -a soft_array
soft_array[0]='git'
soft_array[1]='vim'
soft_array[2]='wget'
soft_array[3]='curl'
soft_array[4]='git'
soft_array[5]='ssh'
soft_array[6]='zsh'


echo "======一键安装常用软件======"
for i in "${soft_array[@]}"
do
    read -p "是否安装${i},输入 n 取消安装：" pick
    if [[ ! $pick =~ [Nn] ]];then
        install_str+=" ${i}"
    fi
done


declare pick_x
read -p "是否安装x-cmd,输入 n 取消安装：" pick_x

declare pick_zsh
read -p "是否一键美化zsh,输入 n 取消：" pick_zsh

declare pick_docker
read -p "是否安装docker,输入 n 取消：" pick_docker

if [[ ! $pick_docker =~ [Nn] ]];then
    declare -A docker_imgs
    docker_imgs['官方']='https://download.docker.com'
    docker_imgs['中国科技大学(默认)']='https://mirrors.ustc.edu.cn/docker-ce'
    docker_imgs['清华大学']='https://mirrors.tuna.tsinghua.edu.cn/docker-ce'
    docker_imgs['阿里云']='https://mirrors.aliyun.com/docker-ce'
    docker_imgs['网易云']='https://mirrors.163.com/docker-ce'


    declare -a docker_img_number
    declare docker_img_number_pick=0
    
    for i in "${!docker_imgs[@]}"; do
        docker_img_number_pick=$((docker_img_number_pick + 1))
        docker_img_number[$docker_img_number_pick]=$i
        echo "${docker_img_number_pick}.${i}"
    done
    read -p "请输入需要选择的镜像站：" docker_img_number_pick
    declare docker_img
    if [[ ! $docker_img_number_pick =~ [1-${#docker_imgs[@]}] ]];then
        docker_img='https://mirrors.ustc.edu.cn/docker-ce'
    else
        docker_img_number_pick=${docker_img_number[$docker_img_number_pick]}
        docker_img=${docker_imgs[$docker_img_number_pick]}
    fi
fi


if [[ ! $pick_x =~ [Nn] ]];then
    
    eval "$(curl https://get.x-cmd.com)"
fi


eval "$install_str -y"
if [[ ! $pick_x =~ [Nn] ]];then
    eval "$(curl https://get.x-cmd.com)"
fi

if [[ ! $pick_zsh =~ [Nn] ]];then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sudo sed -i 's/^#\?ZSH_THEME.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc
    sudo sed -i 's/^#\?plugins.*/plugins=(zsh-syntax-highlighting zsh-autosuggestions command-not-found)/g' ~/.zshrc
    zsh
fi


if [[ ! $pick_docker =~ [Nn] ]];then
    if [[ $version == 'debian' ]];then
        sudo apt-get update
        sudo apt-get install ca-certificates curl -y
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL "${docker_img}/linux/${version}/gpg" -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] ${docker_img}/linux/${version} \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    fi
fi

echo "软件已经全部安装成功"