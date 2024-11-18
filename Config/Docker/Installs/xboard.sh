#!/bin/bash
declare install_path=$1
declare service_port=$2
cd $install_path

declare project_name=$(basename $install_path)
cd ..
rm -rf "$project_name"

git clone -b docker-compose --depth 1 https://github.com/cedar2025/Xboard

if [[ "$project_name" != Xboard ]];then
  mv Xboard "$project_name"
fi

cd "$install_path"

docker compose run -it --rm xboard php artisan xboard:install

docker compose up -d > /dev/null

sleep 5
echo "网站端口默认7001，记得防火墙放行"