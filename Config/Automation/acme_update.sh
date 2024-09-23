declare path="$1"

cat > "${path}/acme_update.sh" << EOF
#!/bin/bash
${HOME}/.acme.sh/acme.sh --upgrade
${HOME}/.acme.sh/acme.sh --renew-all
EOF