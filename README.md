## 功能概述

### 1. Automation（自动化脚本管理）
- **作用**：该分类包含与自动化脚本相关的功能，主要用于管理和执行各种自动化任务。
- **主要文件**：
  - `manage.sh`：提供用户管理脚本的功能，如查看和删除已安装的脚本。
  - `acme_update.sh`：用于更新 ACME 脚本和强制续订所有证书。
  - `backup.sh`：实现数据备份功能，支持本地、百度网盘和阿里云盘备份。
  - `menu.sh`：提供交互式菜单，允许用户选择并执行不同的功能。
  - `up-docker_compose.sh`：用于更新 Docker Compose 服务。
  - `update.sh`：自动更新系统包管理器的配置。

### 2. Docker（Docker 相关功能）
- **作用**：该分类专注于 Docker 相关的功能和服务管理。
- **主要文件**：
  - `image.sh`：管理 Docker 镜像的查看、停止和删除功能。
  - `manage.sh`：提供对 Docker 服务的管理功能。
  - `source.sh`：用于配置 Docker 镜像源。
  - `test.sh`：检查 Docker 是否安装。
  - `alist.sh`、`gitea.sh`、`nginx-proxy-manager.sh`、`safeline.sh`、`siyuan.sh`、`typecho.sh`、`vaultwarden.sh`、`xboard.sh`：这些脚本用于安装和配置不同的 Docker 应用程序。

### 3. Manage（系统管理）
- **作用**：该分类包含与系统管理相关的功能。
- **主要文件**：
  - `install.sh`：用于安装和配置系统工具。
  - `unInstall.sh`：用于卸载系统工具和清理相关配置。

### 4. Other（其他功能）
- **作用**：该分类包含一些其他的实用功能。
- **主要文件**：
  - `bbr_open.sh`：用于开启 BBR 加速。
  - `language.sh`：用于更改系统语言设置。
  - `reinstall.sh`：用于重新安装系统工具。

### 5. User（用户管理）
- **作用**：该分类包含与用户和权限管理相关的功能。
- **主要文件**：
  - `key.sh`：用于管理 SSH 密钥。
  - `manage.sh`：提供用户管理功能，如创建、删除用户。
  - `ssh.sh`：用于管理和配置 SSH 服务。
  - `test.sh`：检查 SSH 客户端是否安装。

### 6. Web（网页相关功能）
- **作用**：该分类主要涉及与网页相关的功能。
- **主要文件**：
  - `acme`：包含与 SSL 证书管理相关的脚本，如申请、管理和测试。
    - `apply.sh`：用于申请 SSL 证书。
    - `manage.sh`：管理已申请的证书。
    - `test.sh`：测试 SSL 证书的有效性。
  - `nginx`：包含与 Nginx 配置相关的脚本。
    - `install.sh`：用于安装 Nginx。
    - `manage.sh`：管理 Nginx 配置。
    - `test.sh`：测试 Nginx 是否正常运行。

### 7. Sources（源管理）
- **作用**：用于管理软件源的配置。
- **主要文件**：
  - `sources.sh`：提供查看和更换软件源的功能。

### 8. VPN（VPN 管理）
- **作用**：用于管理和配置 VPN 服务。
- **主要文件**：
  - `vpn.sh`：提供 VPN 服务的安装和管理功能。

### 9. Software（软件管理）
- **作用**：用于安装常用软件包。
- **主要文件**：
  - 

### 菜单机制
该系统通过菜单提供了一个用户友好的界面，允许用户选择可用的脚本进行执行。菜单机制包括以下两个子功能：

#### 1. test 菜单
- **功能**：test 菜单用于执行特定的测试脚本，验证系统功能的正常运行。用户可以选择要测试的功能，系统会根据选择执行相应的测试脚本。
- **作用**：确保用户在执行其他操作之前，系统的相关功能正常，避免因环境问题导致的错误。

#### 2. menu 菜单
- **功能**：menu 菜单提供了一个用户友好的界面，允许用户选择可用的脚本进行执行。用户通过输入对应的序号来选择脚本，系统会根据用户的选择执行相应的操作。
- **作用**：作为系统的入口，用户可以通过它访问其他功能，包括执行脚本、配置定时任务等。
