declare path="$1"

if [[ -f "${path}/acme.sh" ]];then
  echo "该路径文件已经存在"
fi

cat > "${path}/acme.sh" << EOF
#!/bin/bash
${HOME}/.acme.sh/acme.sh --upgrade
${HOME}/.acme.sh/acme.sh --renew-all
EOF