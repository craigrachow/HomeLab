# instructions from here https://gethomepage.dev/installation/docker/

echo "Make Container for Homepage"
sudo mkdir -pv ./Containers/homepage/

echo "Create Homepage compose.yaml"
echo "services:
  homepage:
    image: ghcr.io/gethomepage/homepage:latest
    container_name: homepage
    ports:
      - 4000:4000
    volumes:
      - ./homepage:/app/config # Make sure your local config directory exists
      - /var/run/docker.sock:/var/run/docker.sock # (optional) For docker integrations
    environment:
      HOMEPAGE_ALLOWED_HOSTS: 192.168.0.110:4000 # required, may need port. See gethomepage.dev/installation/#homepage_allowed_hosts" | sudo tee -a ./Containers/homepage/compose.yaml > /dev/null 

echo "Start Container for Homepage Machine"    
sudo docker-compose -f ./Containers/homepage/compose.yaml up -d
sudo docker ps
