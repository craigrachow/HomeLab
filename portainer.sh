# instructions from here https://github.com/docker/awesome-compose/tree/master/portainer

echo "Make Container for Portainer"
sudo mkdir -pv ./Containers/portainer/portainer_data


echo "Create Portainer compose.yaml"
echo "services:
  portainer:
    image: portainer/portainer-ce
    container_name: portainer
    ports:
      - 9000:9000
      - 9443:9443
    restart: unless-stopped
    volumes:
      - ./portainer_data:/etc/portainer_data
      - /var/run/docker.sock:/var/run/docker.sock" | sudo tee -a ./Containers/portainer/compose.yaml > /dev/null 

echo "Start Container for Portainer Machine"    
sudo docker-compose -f ./Containers/portainer/compose.yaml up -d
sudo docker ps
