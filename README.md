# 🛠 Linux 服务器管理工具箱

一个简单易用的 Linux 服务器管理工具,帮助你快速部署和管理服务器。

## 🔍 系统要求

* 系统支持:

  * Debian 8+
  * Ubuntu 16.04+
  * Arch Linux
* 需要 root 权限
* Linux 内核 5.0+
* 需要预装工具: curl

## 💻 安装方法

### 快速安装

国内用户推荐使用 Gitee 源:

```bash
 bash <(curl -Ls https://gitee.com/lsy22/linuxtool/raw/master/Config/Manage/install.sh)
```

国外用户可以使用 GitHub 源:

```bash
 bash <(curl -Ls https://raw.githubusercontent.com/lsy2246/linuxtool/refs/heads/master/Config/Manage/install.sh)
```

### 使用说明

1. 运行安装脚本
2. 选择安装位置(默认 /var/script)
3. 重启终端或重新连接终端
4. 输入 `tool` 启动工具箱

### ⚠️ 注意事项

* 请确保系统已安装 curl 工具
* 需要 root 权限或 sudo 权限执行
* 如遇到网络问题，建议国内用户使用 Gitee 源

## 📚 功能模块说明

### 🐳 Docker 应用管理 (Docker)

#### 应用安装脚本 (Installs)

* **alist** ： 安装 Alist 网盘管理工具,自动配置管理员密码
* **gitea** ： 部署 Gitea 代码托管平台,包含 MySQL 数据库配置
* **nginx：proxy：manager** ： 安装 Nginx 可视化管理面板
* **safeline** ： 部署长亭 WAF 防火墙
* **siyuan** ： 安装思源笔记服务端,支持自定义访问密码
* **typecho** ： 部署 Typecho 博客系统,自动配置数据库
* **vaultwarden** ： 安装密码管理器服务端,支持中文界面
* **xboard** ： 部署支付系统面板

#### Docker 管理工具

* **image** ： (查看/停止/清理)
* **manage** ： 已安装 Docker 应用管理(查看/删除)
* **source** ： Docker 镜像源管理(查看/切换)

### 🛡️ 系统管理 (System)

#### 基础配置 (Basic)

* **bbr_open** ： 开启 BBR 网络加速
* **language** ： 系统语言切换(中英文)
* **reinstall** ： 系统重装工具

#### 用户管理 (User)

* **account** ： 用户账号管理(创建/删除/修改密码)
* **key** ： SSH 密钥管理(生成/安装)
* **ssh** ： SSH 配置管理(端口/登录方式)

### ⏱️ 自动任务管理 (Task)

#### 任务安装脚本 (Installs)

* **acme_update** ： SSL 证书自动更新任务
* **backup** ： 数据自动备份任务(本地/云端)
* **up：docker_compose** ： Docker 容器自动更新任务
* **update** ： 系统自动更新任务

#### 任务管理工具

* **menu** ： 自动任务管理菜单
* **manage** ： 已安装任务管理(查看/删除)

### 🌐 网站服务管理 (Web)

#### SSL 证书管理 (acme)

* **apply** ： 申请 SSL 证书
* **manage** ： 证书管理(查看信息)
* **test** ： ACME 环境检测

#### Nginx 管理 (nginx)

* **install** ： 配置 Nginx 站点
* **manage** ： 站点管理(查看/删除)
* **test** ： Nginx 环境检测

### 脚本管理 (manage)

* **install** ： 工具箱安装脚本
* **unInstall** ： 工具箱卸载脚本

### 常用软件安装 (software)

### 系统软件源管理 (sources)

### VPN 服务一键部署 (vpn)

## 📝 问题反馈

如有问题或建议:

* 提交 Issue
* 关注公众号: lsy22