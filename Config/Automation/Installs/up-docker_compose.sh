#!/bin/bash

declare path="$1"
if ! command -v docker &> /dev/null; then
    echo "docker未安装"
    exit
fi

declare web_path
read -p "请输入数据目录,默认 /var/www ：" web_path
if [[ -z ${web_path} ]];then
  web_path='/var/www'
fi
cat > "${path}/up-docker_compose.sh" << EOF
#!/bin/bash
for dir in "${web_path}"/*/; do
        cd "\$dir" || exit
        sudo docker compose pull
        sudo docker compose up -d
done
EOF