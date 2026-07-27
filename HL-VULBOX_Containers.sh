#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# HL-VULBOX container-only script
# Purpose:
#   - Create /containers structure
#   - Write docker-compose.yml files
#   - Start vulnerable lab containers
#   - Print a quick verification summary
#
# Assumption:
#   - Base OS setup is already complete
#   - Docker and Docker Compose are already installed
#   - You are running this on HL-VULBOX
# ============================================================

BASE_DIR="/containers"
LAB_USER="${SUDO_USER:-$USER}"

APPS=("juiceshop" "dvwa" "mutillidae" "metasploitable3" "portainer-agent")
RUN_APPS=("juiceshop" "dvwa" "mutillidae" "portainer-agent")

declare -A URLS=(
  ["juiceshop"]="http://192.168.0.209:3000"
  ["dvwa"]="http://192.168.0.209:8080"
  ["mutillidae"]="http://192.168.0.209:81"
  ["portainer-agent"]="tcp://192.168.0.209:9001"
)

msg() { printf '\n==> %s\n' "$*"; }

write_compose() {
  local app="$1"
  local file="$BASE_DIR/$app/docker-compose.yml"

  case "$app" in
    juiceshop)
      cat > "$file" <<'EOF'
services:
  juiceshop:
    image: bkimminich/juice-shop:latest
    container_name: juiceshop
    restart: unless-stopped
    ports:
      - "3000:3000"
EOF
      ;;
    dvwa)
      cat > "$file" <<'EOF'
services:
  dvwa:
    image: vulnerables/web-dvwa:latest
    container_name: dvwa
    restart: unless-stopped
    ports:
      - "8080:80"
EOF
      ;;
    mutillidae)
      cat > "$file" <<'EOF'
services:
  mutillidae:
    image: citizenstig/nowasp:latest
    container_name: mutillidae
    restart: unless-stopped
    ports:
      - "81:80"
EOF
      ;;
    portainer-agent)
      cat > "$file" <<'EOF'
services:
  agent:
    image: portainer/agent:latest
    container_name: portainer-agent
    restart: unless-stopped
    ports:
      - "9001:9001"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
EOF
      ;;
    metasploitable3)
      cat > "$file" <<'EOF'
# Metasploitable3 is usually deployed as a VM, not a container.
# This folder is kept as a placeholder for notes, links, or future lab material.

services: {}
EOF
      ;;
  esac
}

compose_up() {
  local dir="$1"
  (cd "$dir" && docker compose up -d)
}

msg "Creating container directories"
mkdir -p "$BASE_DIR"
for app in "${APPS[@]}"; do
  mkdir -p "$BASE_DIR/$app"
done
chown -R "$LAB_USER:$LAB_USER" "$BASE_DIR" || true

msg "Writing compose files"
for app in "${APPS[@]}"; do
  write_compose "$app"
done
chown -R "$LAB_USER:$LAB_USER" "$BASE_DIR" || true

msg "Starting containers"
for app in "${RUN_APPS[@]}"; do
  compose_up "$BASE_DIR/$app"
done

msg "Verifying services"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

msg "URLs"
for app in "${RUN_APPS[@]}"; do
  printf '%s -> %s\n' "$app" "${URLS[$app]}"
done

printf '\nDone.\n'
