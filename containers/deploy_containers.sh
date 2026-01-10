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
# STEP 3 - SYNC GIT HUB.. where deployment scripts are
# ------------------------------------------------------------
echo "Syncing GitHub Containers Repo..."
GITHUB_REPO="https://github.com/craigrachow/HomeLab.git"
REPO_DIR="/opt/homelab"
TARGET_DIR="/containers"
SUBDIR="containers"

# Clone or update repo
if [ ! -d "$REPO_DIR/.git" ]; then
    git clone "$GITHUB_REPO" "$REPO_DIR"
else
    cd "$REPO_DIR"
    git pull
fi

# Sync containers
rsync -a --delete "$REPO_DIR/$SUBDIR/" "$TARGET_DIR/"


# ------------------------------------------------------------
# STEP 4 — Deploy APPLICATION Containers
# ------------------------------------------------------------

echo "Preparing to deploy the following applications ${APPLICATIONS[@]}"

# loop through each app
for APPLICATIONS in "${APPLICATIONS[@]}"; do
    echo "Deploying ${APPLICATIONS}..."
    bash $BASE_CONTAINER_DIR/${APPLICATIONS}/${APPLICATIONS}.sh
    echo ""
done

# ------------------------------------------------------------
# STEP 5 — Show Status
# ------------------------------------------------------------

echo ""
echo "${APPLICATIONS[@]} have been deployed."
echo ""
docker ps

echo ""
echo "Container deployment script finished successfully."
