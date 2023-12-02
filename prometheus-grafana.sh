# continer from here https://github.com/docker/awesome-compose/tree/master/prometheus-grafana

echo "Make Container for Prometheus & Grafana Machine"
sudo mkdir -pv ./Containers/prometheus-grafana

echo "services:
  prometheus:
    image: prom/prometheus
    container_name: prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    ports:
      - 9090:9090
    restart: unless-stopped
    volumes:
      - ./prometheus:/etc/prometheus
      - prom_data:/prometheus
  grafana:
    image: grafana/grafana
    container_name: grafana
    ports:
      - 3000:3000
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_USER=admin
      - GF_SECURITY_ADMIN_PASSWORD=grafana
    volumes:
      - ./grafana:/etc/grafana/provisioning/datasources
volumes:
  prom_data:" > | sudo tee -a /Containers/prometheus-grafana/compose.yaml > /dev/null 

  
