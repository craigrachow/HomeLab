# continer from here https://jellyfin.org/docs/general/installation/container
# continer from here https://hub.docker.com/r/linuxserver/jellyfin

echo "Make Container for Jellyfin"
sudo mkdir -pv ./Containers/jellyfin


echo "Create Jellyfin compose.yaml"
echo "services:
  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    user: 1000:1000
    ports:
      - 8096:8096
   # network_mode: 'host'
    volumes:
      - ./jellyfin:/config
      - ./jellyfin:/cache
      - /home/user/Downloads:/media
    restart: 'unless-stopped'" | sudo tee -a ./Containers/jellyfin/compose.yaml > /dev/null 


echo "Start Container for Jellyfin Machine"    
sudo docker-compose -f ./Containers/jellyfin/compose.yaml up -d
sudo docker ps
