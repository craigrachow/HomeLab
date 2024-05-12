# continer from here https://jellyfin.org/docs/general/installation/container
# continer from here https://hub.docker.com/r/linuxserver/jellyfin

echo "Make Container for Jellyfin"
sudo mkdir -pv ./Containers/jellyfin

# needed to fic /config/log issue
# chown -R user:user ./jellyfin

echo "Create Jellyfin compose.yaml"
echo "services:
  jellyfin:
    image: jellyfin/jellyfin
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Australia/Darwin
    ports:
      - 8096:8096
    volumes:
      - ./jellyfin:/config
      - ./jellyfin:/cache
      - /home/user/Downloads:/media
    restart: 'unless-stopped'" | sudo tee -a ./Containers/jellyfin/compose.yaml > /dev/null 


echo "Start Container for Jellyfin Machine"    
sudo docker-compose -f ./Containers/jellyfin/compose.yaml up -d
sudo docker ps
