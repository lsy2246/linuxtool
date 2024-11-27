#!/bin/bash
declare installation_directory=$1
declare web_service_port=$2

if ! command -v zip &> /dev/null; then
    echo "zip 未安装"
    exit 1
fi


cd $installation_directory

mkdir data
mkdir php
mkdir -p nginx/conf

cat > "./php/Dockerfile" << 'EOF'
FROM php:fpm

# 更新包列表并安装 pdo_mysql 扩展
RUN apt-get update && \
    apt-get install -y libpq-dev && \
    docker-php-ext-install pdo_mysql && \
    rm -rf /var/lib/apt/lists/*

# 设置 PHP 配置
RUN { \
        echo "output_buffering = 4096"; \
        echo "date.timezone = PRC"; \
    } > /usr/local/etc/php/conf.d/custom.ini
EOF

cat > "./nginx/conf/default.conf" << 'EOF'
server {
    listen 80 default_server;     # 监听 80 端口
    root /var/www/html;           # 网站根目录
    index index.php index.html index.htm;

    access_log /var/log/nginx/typecho_access.log main;  # 访问日志
    if (!-e $request_filename) {
        rewrite ^(.*)$ /index.php$1 last;  # 重写 URL 到 index.php
    }

    location / {
        if (!-e $request_filename) {
            rewrite . /index.php last;  # 如果文件不存在，重写到 index.php
        }
    }

    location ~ \.php(.*)$ {
        fastcgi_pass   php:9000;                   # 转发 PHP 请求到 php-fpm 服务
        fastcgi_index  index.php;
        fastcgi_param  SCRIPT_FILENAME $document_root$fastcgi_script_name;  # 设置脚本文件名参数
        include        fastcgi_params;             # 包含 fastcgi 参数
    }
}
EOF

cat > docker-compose.yml << EOF
services: # 定义多个服务

    nginx: # 服务名称
        image: nginx # 使用的镜像
        ports: # 映射的端口
            - "${web_service_port}:80" # 宿主机端口 ${web_service_port} 映射到容器端口 80
        restart: always # 容器重启策略
        volumes: # 映射文件
            - ./data:/var/www/html # 网站源代码
            - ./nginx/conf:/etc/nginx/conf.d # nginx 站点配置文件
            - ./nginx/logs:/var/log/nginx # nginx 日志文件
        depends_on: # 定义依赖关系
            - php # 依赖 php 服务
        networks: # 要加入的网络
            - typecho # 加入 typecho 网络

    php: # 服务名称
        build: ./php # 构建文件的目录
        restart: always # 容器重启策略
        volumes: # 映射文件
            - ./data:/var/www/html # 网站源代码
        depends_on: # 定义依赖关系
            - mysql # 依赖 mysql 服务
        networks: # 要加入的网络
            - typecho # 加入 typecho 网络

    mysql: # 服务名称
        image: mysql:5.7 # 指定 5.7 版本的 mysql 镜像
        restart: always # 容器重启策略
        volumes: # 要映射的文件
            - ./mysql/data:/var/lib/mysql # mysql 数据
            - ./mysql/logs:/var/log/mysql # mysql 日志
            - ./mysql/conf:/etc/mysql/conf.d # mysql 配置文件
        environment: # 环境变量
            MYSQL_ROOT_PASSWORD: typecho # MySQL root 用户的密码
            MYSQL_DATABASE: typecho # 创建的数据库名称
        networks: # 要加入的网络
            - typecho # 加入 typecho 网络

networks: # 定义的内部网络
    typecho: # 网络名称

EOF

cd data
wget https://github.com/typecho/typecho/releases/download/v1.2.1/typecho.zip -O typecho.zip 
unzip typecho.zip 
rm typecho.zip 

cd $installation_directory

sudo chown -R 1000:1000 $installation_directory

sudo chmod -R 777 data

sudo docker compose up -d

echo "数据库地址：mysql"
echo "数据库用户名：root"
echo "数据库密码：typecho"
echo "数据库名：typecho"

echo "安装完成，请在${installation_directory}/data/config.inc.php末尾添加，防止排版错误"
echo "define('__TYPECHO_SECURE__',true);"

