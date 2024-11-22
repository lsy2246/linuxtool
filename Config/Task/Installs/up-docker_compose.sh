#!/bin/bash

declare docker_compose_path="$1"
if ! command -v docker &> /dev/null; then
    echo "未安装 Docker"
    exit
fi

declare data_directory
read -p "请输入数据目录，默认 /var/www ：" data_directory
if [[ -z ${data_directory} ]];then
  data_directory='/var/www'
fi
cat > "${docker_compose_path}/up-docker_compose.sh" << EOF
#!/bin/bash
for dir in "${data_directory}"/*/; do
        cd "\$dir" || exit
        sudo docker compose pull
        sudo docker compose up -d
done
EOF