# 🛠 Linux 服务器管理工具箱

一个简单易用的 Linux 服务器管理工具,帮助你快速部署和管理服务器。

## 🔍 系统要求

- 系统支持:
  - Debian 8+
  - Ubuntu 16.04+
  - Arch Linux
- 需要 root 权限
- Linux 内核 5.0+
- 需要预装工具: curl/wget

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
3. 重新连接终端
4. 输入 `tool` 启动工具箱

## 🔧 主要功能

### 系统管理
- 用户账号管理(创建/删除用户、修改密码)
- SSH 安全配置(修改端口、密钥管理)
- 系统重装(支持 Debian/Ubuntu/Arch)
- BBR 网络加速
- 语言环境设置

### Docker 应用一键部署
- Alist - 文件管理系统
- Gitea - 轻量级 Git 服务器
- Nginx Proxy Manager - 可视化反向代理管理
- Safeline - WAF 防火墙
- Siyuan - 个人知识管理系统
- Typecho - 轻量级博客系统
- Vaultwarden - 密码管理器
- XBoard - 代理面板

### SSL 证书管理
- 自动申请/续期 SSL 证书
- 支持 HTTP/DNS 验证方式
- 集成 Cloudflare API

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
- 智能切换国内镜像源
- 自动更新软件源

## 📝 问题反馈

如有问题或建议:
- 提交 Issue
- 关注公众号: lsy22

## ⚠️ 注意事项

- 请确保系统已安装 curl 工具
- 需要 root 权限或 sudo 权限执行
- 如遇到网络问题，建议国内用户使用 Gitee 源
