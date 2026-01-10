
#!/bin/bash
# ============================================================
# HomeLab Container Deployment Script
# Purpose:
#  - Update the OS
#  - Prepare container directories
#  - Deploy Portainer using Docker Compose
#  - Leave structure ready for future container deployments
# ============================================================

set -e   # Exit immediately if any command fails

# ------------------------------------------------------------
# CONFIGURATION VARIABLES
# ------------------------------------------------------------

BASE_CONTAINER_DIR="/containers"

# Portainer Variables
PORTAINER_DIR="$BASE_CONTAINER_DIR/portainer"
PORTAINER_DATA_DIR="$PORTAINER_DIR/data"
PORTAINER_COMPOSE_FILE="$PORTAINER_DIR/docker-compose.yml"

PORTAINER_IMAGE="portainer/portainer-ce:latest"
PORTAINER_HTTP_PORT="9000"
PORTAINER_HTTPS_PORT="9443"

# ------------------------------------------------------------
# STEP 1 — Update the Operating System
# ------------------------------------------------------------

echo "Updating operating system..."
sudo apt-get update
sudo apt-get upgrade -y

# ------------------------------------------------------------
# STEP 2 — Create base container directory
# ------------------------------------------------------------

echo "Ensuring base container directory exists..."
sudo mkdir -p "$BASE_CONTAINER_DIR"
sudo chown -R "$USER:$USER" "$BASE_CONTAINER_DIR"

# ------------------------------------------------------------
# STEP 3 — Create Portainer directories
# ------------------------------------------------------------

echo "Creating Portainer directories..."
mkdir -p "$PORTAINER_DIR"
mkdir -p "$PORTAINER_DATA_DIR"

# ------------------------------------------------------------
# STEP 4 — Create Portainer docker-compose.yml
# ------------------------------------------------------------

echo "Creating Portainer Docker Compose file..."

cat <<EOF > "$PORTAINER_COMPOSE_FILE"
version: "3.8"

services:
  portainer:
    image: ${PORTAINER_IMAGE}
    container_name: portainer
    restart: unless-stopped
    ports:
      - "${PORTAINER_HTTP_PORT}:9000"
      - "${PORTAINER_HTTPS_PORT}:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${PORTAINER_DATA_DIR}:/data
EOF

# ------------------------------------------------------------
# STEP 5 — Deploy Portainer
# ------------------------------------------------------------

echo "Deploying Portainer..."
cd "$PORTAINER_DIR"
docker compose up -d

# ------------------------------------------------------------
# STEP 6 — Show Status
# ------------------------------------------------------------

echo ""
echo "Portainer has been deployed."
echo "Access it via:"
echo "  https://<server-ip>:${PORTAINER_HTTPS_PORT}"
echo ""
docker ps | grep portainer || true

# ------------------------------------------------------------
# STEP 7 — Placeholder for future containers
# ------------------------------------------------------------

# Future container deployments should be added here.
# Example:
#
# NEXT_APP_DIR="$BASE_CONTAINER_DIR/myapp"
# mkdir -p "$NEXT_APP_DIR"
# cd "$NEXT_APP_DIR"
# docker compose up -d
#
# This allows this script to become your full HomeLab deployment tool.

echo ""
echo "Container deployment script finished successfully."
