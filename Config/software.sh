#!/bin/bash
echo "正在更新系统包管理器"
declare install_str
declare version="$(cat /etc/os-release | grep "^ID" | awk -F '=' '{print $2}')"
declare status=0

declare pkg
if [[ -f "/usr/bin/apt-get" ]];then
  pkg='apt-get'
  install_str+="${pkg} install -y"
  apt-get update -y
elif [[ -f "/usr/bin/apt" ]];then
  pkg='apt'
  install_str+="${pkg} install -y"
  apt update -y
elif [[ -f "/usr/bin/pacman" ]];then
  pkg='pacman'
  install_str+="${pkg} -Sy --noconfirm"
  pacman -Syu --noconfirm
else
  echo "暂不支持该系统一键安装常用软件"
  exit
fi


declare pick
declare soft_number
declare -A soft_dick
declare -a soft_array
soft_dick['git']=0
soft_dick['vim']=0
soft_dick['wget']=0
soft_dick['curl']=0
soft_dick['sudo']=0
soft_dick['ssh']=0
soft_dick['zsh']=0
soft_dick['zsh-beautify']=1
soft_dick['docker']=1
soft_dick['x-cmd']=1

echo "========$(basename $0 .sh)========"
for i in "${!soft_dick[@]}" ; do
    soft_number=$(( soft_number+1 ))
    soft_array[$soft_number]=$i
    echo "${soft_number}.${i}"
done
echo "请输入需要安装的软件序号（默认安装全部）"
read -p "用 空格 隔开：" pick

if [[ -z $pick ]];then
  for (( i = 1; i <= ${#soft_dick[@]}; i++ )); do
      if [[ $i != 1 ]]; then
          pick="$pick $i"
      else
          pick="$i"
      fi
  done
elif ! [[ $pick -ge 1 && $pick -le ${#soft_dick[@]} || $pick =~ ([1-${#soft_dick[@]}][\s]?)+ ]];then
  echo "输入错误"
  exit
fi

for i in $pick ; do
    if [[ ${soft_dick[${soft_array[$i]}]} == 0 ]]; then
        eval "$install_str ${soft_array[$i]}"
    else
      soft_dick[${soft_array[$i]}]=2
    fi
done

if [[ ${soft_dick['x-cmd']} == 2 ]];then
    eval "$(curl https://get.x-cmd.com)"
fi

if [[ ${soft_dick['docker']} == 2 ]];then
    echo "请选择docker下载镜像站"
    declare -A docker_imgs
    docker_imgs['官方']='https://download.docker.com'
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
    read -p "请选择Docker镜像站：" docker_img_number_pick
    declare docker_img
    if [[ $docker_img_number_pick =~ [1-${#docker_imgs[@]}] ]];then
        docker_img_number_pick=${docker_img_number[$docker_img_number_pick]}
        docker_img=${docker_imgs[$docker_img_number_pick]}
    else
        docker_img=${docker_imgs[1]}
    fi

    if [[ ${pkg} == 'apt' || ${pkg} == 'apt-get' ]];then
        ${pkg} update
        ${pkg} install ca-certificates curl -y
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL "${docker_img}/linux/${version}/gpg" -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] ${docker_img}/linux/${version} \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          tee /etc/apt/sources.list.d/docker.list > /dev/null
        ${pkg} update
        ${pkg} install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    elif [[ ${pkg} == 'pacman' ]];then
        pacman -Sy docker --noconfirm
        systemctl start docker.service
        systemctl enable docker.service
        usermod -aG docker $USER
        newgrp docker
    fi
fi


if [[ ${soft_dick['zsh-beautify']} == 2 ]];then
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sed 's/read -r opt//g'| sed 's/exec zsh -l//g'| sh
    while [[ ! -d "$HOME/.oh-my-zsh" ]]; do
        sleep 3
    done
    git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i 's/^#\?ZSH_THEME.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc
    sed -i 's/^#\?plugins.*/plugins=(zsh-syntax-highlighting zsh-autosuggestions command-not-found)/g' ~/.zshrc
    chsh -s /bin/zsh
    exec zsh -l
fi



echo "软件已经全部安装成功"