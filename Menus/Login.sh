#!/bin/bash
declare pick
echo "========Login========"
echo "1.修改root密码"
echo "2.ssh安装密钥"
echo "3.新建用户"
echo "4.管理ssh登录方式"
echo "5.更换ssh端口"
echo "任意输入返回主菜单"
echo "========Login========"
read -p "请输入要使用的功能：" pick


case $pick in
    1)
        declare password
    	read -p "请输入root密码：" password
        echo "root:$password" |sudo chpasswd
        sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
        sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
        sudo systemctl restart sshd.service
    	echo "修改成功当前root密码为：$password"
        ;;
    2)
        declare key
        echo "请输入公钥或文件路径："
        echo "默认：$HOME/.ssh/id_rsa.pub"
        read -p "回车默认：" key

        if [[ -z $key ]];then
            key="$HOME/.ssh/id_rsa.pub"
        fi

        if [[ -f $key ]];then
            key=$(cat "$key")
        fi
        if [[ ! $key =~ ^ssh-(rsa|ecdsa-sha2-nistp[0-9]+|ed25519|dss) ]];then
            echo "公钥不合法"
            exit 1
        fi

        mkdir -p "$HOME/.ssh"
        echo "$key" > "$HOME/.ssh/authorized_keys"

        chmod 600 "$HOME/.ssh/authorized_keys"
        chmod 700 "$HOME/.ssh"

        sudo sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config

        declare pick2
        echo "是否关闭密码登录："
        read -p "输入 n 取消关闭：" pick2

        if [[ ! $pick2 =~ [Nn] ]];then
            sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
        fi


        sudo systemctl restart sshd.service

        echo "密钥安装完成"
        ;;
    3)
        declare user_name
        read -p "请输入你想创建的用户名：" user_name

        if id "$user_name" &>/dev/null; then
            echo "用户 $user_name 已存在。"
            exit 1
        fi

        useradd -m -s /bin/bash "$user_name"

        if grep -q "^$user_name " /etc/sudoers;then
            sudo sed -i "s/^#\?$user_name.*/lsy ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers
        else
            sudo echo "lsy ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
        fi


        declare pick
        echo "用户登录方式"
        echo "y.密码登录"
        echo "n.使用root用户公钥"
    	    read -p "默认y，请输入：" pick
        if [[ ! $pick =~ [Nn] ]];then
            declare password
            read -p "请输入密码：" password
            echo "$user_name:$password" |sudo chpasswd
            sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
            echo "创建成功"
            echo "账号：$user_name"
            echo "密码：$password"
        else
            sudo sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
            su "$user_name" -c "mkdir -p '/home/$user_name/.ssh'"
            sudo cp "/root/.ssh/authorized_keys" "/home/$user_name/.ssh/authorized_keys"
            sudo chown lsy:lsy "/home/$user_name/.ssh/authorized_keys"
            su "$user_name" -c "chmod 600 '/home/$user_name/.ssh/authorized_keys'"
            su "$user_name" -c "chmod 700 '/home/$user_name/.ssh/'"

            echo "创建成功"
            echo "账号：$user_name"
            echo "密钥登录"
        fi

        declare pick2
        echo "是否关闭root登录"
        read -p "输入 n 取消关闭：" pick2

        if [[ ! $pick2 =~ [Nn] ]];then
            sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
            echo "root用户登录已关闭"
        fi

        sudo systemctl restart sshd.service

        ;;
    4)
        declare pick_root
        declare pick2_key
        declare pick2_password
        echo "是否关闭root登录"
        read -p "输入 n 关闭：" pick_root
        echo "是否关闭密码登录"
        read -p "输入 n 关闭：" pick2_password
        echo "是否关闭密钥登录"
        read -p "输入 n 关闭：" pick2_key

        if [[ ! $pick_root =~ [Nn] ]];then
            sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
            echo "root用户登录：开启"
        else
            sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config
            echo "root用户登录：关闭"
        fi

        if [[ ! $pick2_password =~ [Nn] ]];then
            sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
            echo "密码登录：开启"
        else
            sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/g' /etc/ssh/sshd_config
            echo "密码登录：关闭"
        fi

        if [[ ! $pick2_key =~ [Nn] ]];then
            sudo sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
            echo "密钥登录：开启"
        else
            sudo sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication no/g' /etc/ssh/sshd_config
            echo "密钥登录：关闭"
        fi

        sudo systemctl restart sshd.service
        ;;
    5)
        read -p "请输入需要修改的端口号(默认22): " port_number

        if [[ -z $port_number ]];then
            port_number=22
        fi

        if ! [[ $port_number =~ ^[0-9]+$ ]] || ! ((port_number > 0 && port_number < 65535)); then
            echo "端口不合法"
            exit
        fi

        if sudo lsof -i :$port_number -t >/dev/null; then
            echo "$port_number 端口已被占用"
            exit
        fi

        sudo sed -i "s/^#\?Port.*/Port $port_number/g" /etc/ssh/sshd_config

        sudo systemctl restart sshd.service

        echo "端口已经修改为$port_number，记得防火墙放行"
        ;;
    *)
        clear
esac

