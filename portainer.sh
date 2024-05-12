# instructions from here https://github.com/docker/awesome-compose/tree/master/portainer

echo "Make Container for Portainer"
sudo mkdir -pv ./Containers/portainer


echo "Create Portainer compose.yaml"
echo "services:
  portainer:
    image: portainer/portainer-ce:alpine" | sudo tee -a ./Containers/portainer/compose.yaml > /dev/null 

echo "Start Container for Portainer Machine"    
sudo docker-compose -f ./Containers/portainer/compose.yaml up -d
sudo docker ps
