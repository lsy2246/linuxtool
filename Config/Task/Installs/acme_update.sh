declare update_path="$1"

cat > "${update_path}/acme_update.sh" << EOF
#!/bin/bash
${HOME}/.acme.sh/acme.sh --upgrade
${HOME}/.acme.sh/acme.sh --renew-all --force
EOF