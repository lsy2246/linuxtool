#!/bin/bash
echo "正在更新系统包管理器"
declare install_command
declare os_version="$(cat /etc/os-release | grep "^ID" | awk -F '=' '{print $2}')"
declare install_status=0

declare package_manager
if [[ -f "/usr/bin/apt-get" ]];then
  package_manager='apt-get'
  install_command+="${package_manager} install -y"
  apt-get update -y
elif [[ -f "/usr/bin/apt" ]];then
  package_manager='apt'
  install_command+="${package_manager} install -y"
  apt update -y
elif [[ -f "/usr/bin/pacman" ]];then
  package_manager='pacman'
  install_command+="${package_manager} -Sy --noconfirm"
  pacman -Syu --noconfirm
else
  echo "暂不支持该系统一键安装常用软件"
  exit
fi

declare selected_packages
declare package_count
declare -A package_options
declare -a package_names
package_options['git']=0
package_options['vim']=0
package_options['wget']=0
package_options['curl']=0
package_options['sudo']=0
package_options['ssh']=0
package_options['zsh']=0
package_options['zsh-beautify']=1
package_options['docker']=1
package_options['x-cmd']=1

echo "========$(basename $0 .sh)========"
for i in "${!package_options[@]}" ; do
    package_count=$(( package_count+1 ))
    package_names[$package_count]=$i
    echo "${package_count}.${i}"
done
echo "请输入需要安装的软件序号（默认安装全部）"
read -p "用 空格 隔开：" selected_packages

if [[ -z $selected_packages ]];then
  for (( i = 1; i <= ${#package_options[@]}; i++ )); do
      if [[ $i != 1 ]]; then
          selected_packages="$selected_packages $i"
      else
          selected_packages="$i"
      fi
  done
elif ! [[ $selected_packages -ge 1 && $selected_packages -le ${#package_options[@]} || $selected_packages =~ ([1-${#package_options[@]}][\s]?)+ ]];then
  echo "输入错误"
  exit
fi

for i in $selected_packages ; do
    if [[ ${package_options[${package_names[$i]}]} == 0 ]]; then
        eval "$install_command ${package_names[$i]}"
    else
      package_options[${package_names[$i]}]=2
    fi
done

if [[ ${package_options['x-cmd']} == 2 ]];then
    eval "$(curl https://get.x-cmd.com)"
fi

if [[ ${package_options['docker']} == 2 ]];then
    echo "请选择docker下载镜像站"
    declare -A docker_mirrors
    docker_mirrors['官方']='https://download.docker.com'
    docker_mirrors['清华大学']='https://mirrors.tuna.tsinghua.edu.cn/docker-ce'
    docker_mirrors['阿里云']='https://mirrors.aliyun.com/docker-ce'
    docker_mirrors['网易云']='https://mirrors.163.com/docker-ce'

    declare -a docker_mirror_options
    declare docker_mirror_choice=0
    
    for i in "${!docker_mirrors[@]}"; do
        docker_mirror_choice=$((docker_mirror_choice + 1))
        docker_mirror_options[$docker_mirror_choice]=$i
        echo "${docker_mirror_choice}.${i}"
    done
    read -p "请选择Docker镜像站(默认 1)：" docker_mirror_choice
    declare docker_mirror
    if [[ $docker_mirror_choice =~ [1-${#docker_mirrors[@]}] ]];then
        docker_mirror_choice=${docker_mirror_options[$docker_mirror_choice]}
        docker_mirror=${docker_mirrors[$docker_mirror_choice]}
    else
        docker_mirror=${docker_mirrors[${docker_mirror_options[1]}]}
    fi

    if [[ ${package_manager} == 'apt' || ${package_manager} == 'apt-get' ]];then
        ${package_manager} update
        ${package_manager} install ca-certificates curl -y
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL "${docker_mirror}/linux/${os_version}/gpg" -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] ${docker_mirror}/linux/${os_version} \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          tee /etc/apt/sources.list.d/docker.list > /dev/null
        ${package_manager} update
        ${package_manager} install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    elif [[ ${package_manager} == 'pacman' ]];then
        pacman -Sy docker --noconfirm
        systemctl start docker.service
        systemctl enable docker.service
        usermod -aG docker $USER
        newgrp docker
    fi
fi

if [[ ${package_options['zsh-beautify']} == 2 ]];then
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