# This file prepares a linux server for homelab deployment.
# Ensure this is executed in the correct directory. eg /HomeLab. 
# git pull https://github.com/craigrachow/HomeLab

echo "starting prepserver.sh script"

echo "Update OS and Repo's"
sudo apt-get update -y
sudo apt-get install docker.io docker-cli docker-compose -y


# Create Software/Storage/Containers Directories - maybe not needed as the git pull should create

echo "Create Docker Storage"
sudo mkdir -vp {Storage/shared,Containers}


echo "ending prepserver.sh script"
