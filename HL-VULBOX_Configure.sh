
#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# HL-VULBOX bootstrap script
# Purpose:
#   - Configure the lab VM
#   - Install SSH, XRDP, Docker, and Docker Compose
#   - Create /containers app folders
#   - Deploy vulnerable lab containers
#   - Print a verification summary
#
# Notes:
#   - Run from the Proxmox console or local console, not over SSH,
#     because the network configuration may restart the interface.
#   - Metasploitable3 is left as a placeholder because it is usually
#     deployed as a VM rather than a container.
# ============================================================

if [[ "${EUID}" -ne 0 ]]; then
  exec sudo -E bash "$0" "$@"
fi

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------
HOSTNAME_TARGET="HL-VULBOX"
IFACE="eth0"
STATIC_CIDR="192.168.0.209/24"
GATEWAY="192.168.0.1"
DNS_SERVERS=("1.1.1.1" "8.8.8.8")

BASE_DIR="/containers"
LAB_USER="${SUDO_USER:-${USER}}"

# App list for looped directory creation and deployment
APPS=("juiceshop" "dvwa" "mutillidae" "metasploitable3" "portainer-agent")

# App URLs for summary output
declare -A APP_URLS=(
  ["juiceshop"]="http://192.168.0.209:3000"
  ["dvwa"]="http://192.168.0.209:8080"
  ["mutillidae"]="http://192.168.0.209:81"
  ["portainer-agent"]="tcp://192.168.0.209:9001"
)

# ------------------------------------------------------------
# Small helper functions
# ------------------------------------------------------------
msg() { printf '\n==> %s\n' "$*"; }
ok()  { printf '[OK] %s\n' "$*"; }
warn(){ printf '[WARN] %s\n' "$*"; }

compose_up() {
  local dir="$1"
  ( cd "$dir" && docker compose up -d )
}

write_compose_file() {
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
      # Metasploitable3 is normally a VM-based lab target.
      # This placeholder keeps the folder structure consistent.
      cat > "$file" <<'EOF'
# Metasploitable3 is usually deployed as a VM, not a container.
# Keep this folder as a placeholder for notes, links, or a future target.
# If you choose to containerise a lab target here, replace this file.

services: {}
EOF
      ;;
  esac
}

report_service() {
  local svc="$1"
  if systemctl is-active --quiet "$svc"; then
    ok "$svc is active"
  else
    warn "$svc is not active"
  fi
}

report_port() {
  local port="$1"
  if ss -ltn | awk '{print $4}' | grep -q ":${port}$"; then
    ok "Port ${port} is listening"
  else
    warn "Port ${port} is not listening"
  fi
}

# ------------------------------------------------------------
# 1) Hostname
# ------------------------------------------------------------
msg "Setting hostname to ${HOSTNAME_TARGET}"
hostnamectl set-hostname "$HOSTNAME_TARGET"
if grep -qE '^127\.0\.1\.1' /etc/hosts; then
  sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t${HOSTNAME_TARGET}/" /etc/hosts
else
  echo "127.0.1.1    ${HOSTNAME_TARGET}" >> /etc/hosts
fi
ok "Hostname configured"

# ------------------------------------------------------------
# 2) Update and upgrade
# ------------------------------------------------------------
msg "Updating package lists and upgrading the system"
apt-get update
apt-get full-upgrade -y
apt-get autoremove -y
ok "System updated"

# ------------------------------------------------------------
# 3) Static IP configuration
# ------------------------------------------------------------
msg "Configuring static IP on ${IFACE}"

DNS_JOINED="${DNS_SERVERS[*]}"

if command -v nmcli >/dev/null 2>&1; then
  # Use NetworkManager if available; this is the most reliable method on Kali desktops.
  CONN_NAME="$(nmcli -t -f NAME,DEVICE con show --active 2>/dev/null | awk -F: -v iface="$IFACE" '$2==iface {print $1; exit}')"

  if [[ -z "${CONN_NAME}" ]]; then
    CONN_NAME="$IFACE"
    nmcli con add type ethernet ifname "$IFACE" con-name "$CONN_NAME" \
      ipv4.addresses "$STATIC_CIDR" ipv4.gateway "$GATEWAY" ipv4.dns "$DNS_JOINED" \
      ipv4.method manual autoconnect yes
  else
    nmcli con modify "$CONN_NAME" ipv4.addresses "$STATIC_CIDR" ipv4.gateway "$GATEWAY" ipv4.dns "$DNS_JOINED" ipv4.method manual
  fi

  nmcli con down "$CONN_NAME" || true
  nmcli con up "$CONN_NAME"
  ok "NetworkManager profile configured for ${IFACE}"
else
  # Fallback for systems without NetworkManager.
  mkdir -p /etc/network/interfaces.d
  cat > "/etc/network/interfaces.d/${IFACE}.cfg" <<EOF
auto ${IFACE}
iface ${IFACE} inet static
    address 192.168.0.209
    netmask 255.255.255.0
    gateway ${GATEWAY}
    dns-nameservers ${DNS_JOINED}
EOF

  if ! grep -q '^source /etc/network/interfaces.d/\*' /etc/network/interfaces 2>/dev/null; then
    echo 'source /etc/network/interfaces.d/*' >> /etc/network/interfaces
  fi

  systemctl restart networking || true
  ok "Fallback network config written for ${IFACE}"
fi

# ------------------------------------------------------------
# 4) SSH and XRDP
# ------------------------------------------------------------
msg "Installing SSH server and XRDP"
apt-get install -y openssh-server xrdp xorgxrdp
systemctl enable --now ssh
systemctl enable --now xrdp
ok "SSH and XRDP installed and enabled"

# Optional nicety for XRDP sessions on XFCE-based Kali installs.
if [[ -f "/home/${LAB_USER}/.xsession" ]]; then
  :
else
  echo "xfce4-session" > "/home/${LAB_USER}/.xsession" || true
  chown "${LAB_USER}:${LAB_USER}" "/home/${LAB_USER}/.xsession" || true
fi

# ------------------------------------------------------------
# 5) Docker and Docker Compose
# ------------------------------------------------------------
msg "Installing Docker and Docker Compose"
apt-get install -y ca-certificates curl gnupg lsb-release docker.io docker-compose-plugin
systemctl enable --now docker

# Add the interactive lab user to the docker group so future logins can use docker without sudo.
if id "$LAB_USER" >/dev/null 2>&1; then
  usermod -aG docker "$LAB_USER"
fi

ok "Docker installed and enabled"

# ------------------------------------------------------------
# xx) Shut Down Scheduled Task
# ------------------------------------------------------------
# Configure cronjob to shut the machine down every 6 hours on the hour.
( crontab -l 2>/dev/null; echo "0 */6 * * * /sbin/shutdown -h now" ) | crontab -

# ------------------------------------------------------------
# 6) Container directory structure
# ------------------------------------------------------------
msg "Creating container directory structure"
mkdir -p "$BASE_DIR"
for app in "${APPS[@]}"; do
  mkdir -p "$BASE_DIR/$app"
done
chown -R "${LAB_USER}:${LAB_USER}" "$BASE_DIR" || true
ok "Directories created under ${BASE_DIR}"

# ------------------------------------------------------------
# 7) Compose files
# ------------------------------------------------------------
msg "Writing docker-compose.yml files"
for app in "${APPS[@]}"; do
  write_compose_file "$app"
done
chown -R "${LAB_USER}:${LAB_USER}" "$BASE_DIR" || true
ok "Compose files written"

# ------------------------------------------------------------
# 8) Deploy containers
# ------------------------------------------------------------
msg "Starting containers"
DEPLOYED_APPS=("juiceshop" "dvwa" "mutillidae" "portainer-agent")

for app in "${DEPLOYED_APPS[@]}"; do
  compose_up "$BASE_DIR/$app"
done

ok "Requested containers started"

# ------------------------------------------------------------
# 9) Verification summary
# ------------------------------------------------------------
msg "Verification summary"

report_service ssh
report_service xrdp
report_service docker

echo
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

echo
echo "Application URLs:"
for app in "juiceshop" "dvwa" "mutillidae" "portainer-agent"; do
  echo " - ${app}: ${APP_URLS[$app]}"
done

echo
echo "Notes:"
echo " - Juice Shop: ${APP_URLS[juiceshop]}"
echo " - DVWA: ${APP_URLS[dvwa]}"
echo " - Mutillidae: ${APP_URLS[mutillidae]}"
echo " - Portainer Agent: ${APP_URLS[portainer-agent]} (not a browser URL; it is for Portainer Server connectivity)"
echo " - Metasploitable3 folder created as a placeholder because it is typically a VM-based target"

# Ports that should be listening for the lab services
for port in 22 3389 3000 8080 81 9001; do
  report_port "$port"
done

echo
ok "HL-VULBOX bootstrap completed"
