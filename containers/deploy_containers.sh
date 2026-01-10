
#!/bin/bash
# ============================================================
# HomeLab Container Deployment Script
# Purpose:
#  - Update the OS
#  - Prepare container directories
#  - Deploy Containers using Docker Compose
# ============================================================

set -e   # Exit immediately if any command fails

# ------------------------------------------------------------
# CONFIGURATION VARIABLES
# ------------------------------------------------------------

BASE_CONTAINER_DIR="/containers"

# Container App Variables
APPLICATIONS=('portainer' 'Banana' 'Orange')


echo "${APPLICATIONS[@]}"           # All elements have been deployed

for i in "${arrayName[@]}"; do
  echo "$i run this command YELL YELL YELL"
done

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
# STEP 3 — Deploy APP Containers
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
docker ps

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
