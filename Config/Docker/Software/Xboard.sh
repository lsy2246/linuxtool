#!/bin/bash
declare path=$1
declare port=$2
cd $path

declare namediv=$(basename $path)
cd ..
rm -rf "$namediv"

git clone -b  docker-compose --depth 1 https://github.com/cedar2025/Xboard

if [[ "$namediv" != Xboard ]];then
  mv Xboard "$namediv"
fi

cd "$path"

docker compose run -it --rm xboard php artisan xboard:install

docker compose up -d > /dev/null

sleep 5
echo "网站端口默认7001，记得防火墙放行"