# This file prepares a linux server for homelab deployment.
# Ensure this is executed in the correct directory. eg /HomeLab. 
# git pull https://github.com/craigrachow/HomeLab

echo "starting prepserver.sh script"

# Update OS and Repo's
apt-get install docker-cli
apt-get install docker.io


# Create Software/Storage/Containers Directories - maybe not needed as the git pull should create


