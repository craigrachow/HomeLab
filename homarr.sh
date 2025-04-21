# instructions from here https://homarr.dev/docs/getting-started/installation/docker/#docker-compose

echo "Make Container for Homarr"
sudo mkdir -pv ./Containers/homarr/homarr_data


echo "Create Homarr compose.yaml"
echo "services:
    homarr:
      container_name: homarr
      image: ghcr.io/homarr-labs/homarr:latest
      restart: unless-stopped
    ports:
      - 7575:7575
    environment:
      - SECRET_ENCRYPTION_KEY=cca7b7b2e0997f0c48a8be2cd949ce715f36cc5c8844b42f8cbdaf0ff99307b5
    volumes:
      - ./homarr_data:/etc/homarr_data" | sudo tee -a ./Containers/homarr/compose.yaml > /dev/null 

echo "Start Container for Homarr Machine"    
sudo docker-compose -f ./Containers/homarr/compose.yaml up -d
sudo docker ps
