# instructions from here https://docs.techdox.nz/ittools/

echo "Make Container for ITtools"
sudo mkdir -pv ./Containers/ittools/ittools_data


echo "Create ITtools compose.yaml"
echo "services:
    ittools:
      container_name: ittools
      image: image: 'corentinth/it-tools:latest'  # The Docker image to use.
      restart: unless-stopped
      ports:
        - '8055:80'
      volumes:
        - ./ittools_data:/etc/ittools_data" | sudo tee -a ./Containers/ittools/compose.yaml > /dev/null 

echo "Start Container for ITtools Machine"    
sudo docker-compose -f ./Containers/ittools/compose.yaml up -d
sudo docker ps
