# 🛠 Linux 服务器管理工具箱

一个功能强大的 Linux 服务器运维管理工具集,提供图形化菜单界面,简化各类运维任务。

## ✨ 主要特性

- 🎯 智能环境检测,自动安装依赖
- 🎨 中文交互式菜单界面
- 📦 模块化设计,功能可扩展
- 🔒 安全可靠,支持权限控制
- 🚀 一键部署常用服务

## 🔧 核心功能

### 系统管理
- 用户账号管理
- SSH 安全配置
- 系统重装
- BBR 网络加速
- 语言环境设置

### Docker 应用
一键部署以下应用:
- Alist (文件管理)
- Gitea (Git 服务器) 
- Nginx Proxy Manager (反向代理)
- Safeline (WAF 防火墙)
- Siyuan (知识管理)
- Typecho (博客系统)
- Vaultwarden (密码管理)
- XBoard (代理面板)

### SSL 证书
- 自动申请/续期
- HTTP/DNS 验证
- Cloudflare API 集成

### Web 服务
- Nginx 配置管理
- 站点管理
- 反向代理设置

### 自动化任务
- 系统更新
- 数据备份(支持网盘)
- Docker 服务更新
- 证书自动续期

### 软件源管理
- 智能切换镜像源
- 自动更新软件源

## 💻 安装方法

### 快速安装
```bash
wget -O install.sh https://raw.githubusercontent.com/lsy2246/linuxtool/main/install.sh && bash install.sh
```

### 使用说明
1. 运行安装脚本
2. 选择安装位置(默认 /var/script)
3. 重新连接终端
4. 输入 `tool` 启动工具箱

## 🔍 系统要求

- 系统: Debian/Ubuntu/Arch Linux
- 权限: root 权限
- 内核: Linux 5.0+
- 工具: curl/wget

## 📝 问题反馈

如有问题或建议:
- 提交 Issue
- 关注公众号: lsy22
