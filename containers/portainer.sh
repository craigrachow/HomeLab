
#!/bin/bash
APP='portainer'
# ============================================================
# HomeLab Container Deployment Script
# Purpose:
#  - Deploy $APP using Docker Compose
# ============================================================

set -e   # Exit immediately if any command fails

# ------------------------------------------------------------
# CONFIGURATION VARIABLES
# ------------------------------------------------------------

BASE_CONTAINER_DIR="/containers"

# $APP Variables
APP_DIR="$BASE_CONTAINER_DIR/$APP"
APP_DATA_DIR="$APP_DIR/data"
APP_COMPOSE_FILE="$APP_DIR/docker-compose.yml"

APP_IMAGE="$APP/$APP-ce:latest"
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
# STEP 2 — Create $APP docker-compose.yml
# ------------------------------------------------------------

echo "Creating $APP Docker Compose file..."

cat <<EOF > "$APP_COMPOSE_FILE"

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

echo ""
echo "$APP deployment script finished successfully."
echo ""
