
#!/bin/bash
# ============================================================
# HomeLab Container Deployment Script
# Purpose:
#  - Deploy Portainer using Docker Compose
# ============================================================

set -e   # Exit immediately if any command fails

# ------------------------------------------------------------
# CONFIGURATION VARIABLES
# ------------------------------------------------------------
APP='portainer'
BASE_CONTAINER_DIR="/containers"

# Portainer Variables
APP_DIR="$BASE_CONTAINER_DIR/$APP"
APP_DATA_DIR="$APP_DIR/data"
APP_COMPOSE_FILE="$APP_DIR/docker-compose.yml"

APP_IMAGE="portainer/portainer-ce:latest"
APP_HTTP_PORT="9000"
APP_HTTPS_PORT="9443"

# ------------------------------------------------------------
# STEP 1 — Create App directories
# ------------------------------------------------------------
echo "###########################"
echo "DEPLOYING $APP CONTAINER..."
echo "###########################"

echo "Creating App directories..."
mkdir -p "$APP_DIR"
mkdir -p "$APP_DATA_DIR"

# ------------------------------------------------------------
# STEP 2 — Create Portainer docker-compose.yml
# ------------------------------------------------------------

echo "Creating $APP Docker Compose file..."

cat <<EOF > "$APP_COMPOSE_FILE"
version: "3.8"

services:
  $APP:
    image: ${APP_IMAGE}
    container_name: $APP
    restart: unless-stopped
    ports:
      - "${APP_HTTP_PORT}:9000"
      - "${APP_HTTPS_PORT}:9443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ${APP_DATA_DIR}:/data
EOF

# ------------------------------------------------------------
# STEP 3 — Deploy $APP
# ------------------------------------------------------------

echo "Deploying $APP..."
cd "$APP_DIR"
docker compose up -d

# ------------------------------------------------------------
# STEP 4 — Show Status
# ------------------------------------------------------------

echo ""
echo "$APP has been deployed."
echo "Access it via:"
echo "  https://<server-ip>:${APP_HTTPS_PORT}"
echo ""
docker ps | grep $APP || true

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
echo "$APP deployment script finished successfully."
