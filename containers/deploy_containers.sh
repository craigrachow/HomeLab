#!/bin/bash
# ============================================================
# HomeLab Container Deployment Script
# Purpose:
#  - Update the OS
#  - Prepare container directories
#  - Deploy Application Containers using Docker Compose (each application will have its own sub-file)
# ============================================================

set -e   # Exit immediately if any command fails

# ------------------------------------------------------------
# CONFIGURATION VARIABLES
# ------------------------------------------------------------

BASE_CONTAINER_DIR="/containers"

# Add or remove apps here — the loop will automatically adjust
APPLICATIONS=("portainer" "app2" "app3")




#PORTAINER_DIR="$BASE_CONTAINER_DIR/portainer"
#PORTAINER_DATA_DIR="$PORTAINER_DIR/data"
#PORTAINER_COMPOSE_FILE="$PORTAINER_DIR/docker-compose.yml"

#PORTAINER_IMAGE="portainer/portainer-ce:latest"
#PORTAINER_HTTP_PORT="9000"
#PORTAINER_HTTPS_PORT="9443"

# ------------------------------------------------------------
# STEP 1 — Update the Operating System
# ------------------------------------------------------------

#echo "Updating operating system..."
#sudo apt-get update
#sudo apt-get upgrade -y

# ------------------------------------------------------------
# STEP 2 — Create base container directory
# ------------------------------------------------------------

echo "Ensuring base container directory exists..."
sudo mkdir -p "$BASE_CONTAINER_DIR"
sudo chown -R "$USER:$USER" "$BASE_CONTAINER_DIR"

# ------------------------------------------------------------
# STEP 3 — Deploy APPLICATION Containers
# ------------------------------------------------------------

echo "Preparing to deploy the following applications ${APPLICATIONS[@]}"

# loop through each app
for APPLICATIONS in "${APPLICATIONS[@]}"; do
    echo "Deploying ${APPLICATIONS}..."
    bash ${APPLICATIONS}.sh
    echo ""
done

# ------------------------------------------------------------
# STEP 4 — Show Status
# ------------------------------------------------------------

echo ""
echo "${APPLICATIONS[@]} have been deployed."
echo ""
docker ps

echo ""
echo "Container deployment script finished successfully."
