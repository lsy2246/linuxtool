## 功能概述

### 1. Automation（自动化脚本管理）
- **作用**：管理和执行各种自动化任务。
- **主要文件**：
  - `manage.sh`：用户管理脚本。
  - `acme_update.sh`：更新 ACME 脚本和续订证书。
  - `backup.sh`：数据备份，支持多种备份方式。
  - `menu.sh`：交互式菜单，选择执行功能。
  - `up-docker_compose.sh`：更新 Docker Compose 服务。
  - `update.sh`：自动更新系统包管理器配置。

### 2. Docker（Docker 相关功能）
- **作用**：Docker 功能和服务管理。
- **主要文件**：
  - `image.sh`：管理 Docker 镜像。
  - `manage.sh`：Docker 服务管理。
  - `source.sh`：配置 Docker 镜像源。
  - `test.sh`：检查 Docker 安装。
  - `alist.sh`、`gitea.sh`、`nginx-proxy-manager.sh`、`safeline.sh`、`siyuan.sh`、`typecho.sh`、`vaultwarden.sh`、`xboard.sh`：安装和配置不同 Docker 应用。

### 3. Manage（系统管理）
- **作用**：系统管理相关功能。
- **主要文件**：
  - `install.sh`：安装和配置系统工具。
  - `unInstall.sh`：卸载系统工具和清理配置。

### 4. Other（其他功能）
- **作用**：其他实用功能。
- **主要文件**：
  - `bbr_open.sh`：开启 BBR 加速。
  - `language.sh`：更改系统语言设置。
  - `reinstall.sh`：重新安装系统工具。

### 5. User（用户管理）
- **作用**：用户和权限管理功能。
- **主要文件**：
  - `key.sh`：管理 SSH 密钥。
  - `manage.sh`：用户管理功能。
  - `ssh.sh`：管理和配置 SSH 服务。
  - `test.sh`：检查 SSH 客户端安装。

### 6. Web（网页相关功能）
- **作用**：网页相关功能。
- **主要文件**：
  - `acme`：SSL 证书管理脚本。
    - `apply.sh`：申请 SSL 证书。
    - `manage.sh`：管理已申请证书。
    - `test.sh`：测试 SSL 证书有效性。
  - `nginx`：Nginx 配置相关脚本。
    - `install.sh`：安装 Nginx。
    - `manage.sh`：管理 Nginx 配置。
    - `test.sh`：测试 Nginx 是否正常运行。

### 7. Sources.sh（源管理）
- **作用**：管理软件源配置。

### 8. VPN（VPN 管理）
- **作用**：VPN 服务的安装

### 9. Software（软件管理）
- **作用**：安装常用软件包。


### 菜单机制
该系统通过菜单提供用户友好的界面，允许用户选择可用脚本执行。菜单机制包括以下两个子功能：

#### 1. test 菜单
- **功能**：执行特定测试脚本，验证系统功能正常。

#### 2. menu 菜单
- **功能**：用户友好的界面，选择可用脚本执行。
