# continer from here https://github.com/docker/awesome-compose/tree/master/prometheus-grafana

echo "Make Container for Prometheus & Grafana Machine"
sudo mkdir -pv ./Containers/prometheus-grafana


echo "Create Prometheus & Grafana compose.yaml"
echo "services:
  prometheus:
    image: prom/prometheus
    container_name: prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yaml'
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
  prom_data:" | sudo tee -a ./Containers/prometheus-grafana/compose.yaml > /dev/null 


  echo "Create Grafana datasource.yaml"
  sudo mkdir -pv ./Containers/prometheus-grafana/grafana
  echo "apiVersion: 1

datasources:
- name: Prometheus
  type: prometheus
  url: http://prometheus:9090 
  isDefault: true
  access: proxy
  editable: true" | sudo tee -a ./Containers/prometheus-grafana/grafana/datasource.yml > /dev/null 

   echo "Create prometheus.yaml"
   sudo mkdir -pv ./Containers/prometheus-grafana/prometheus
   echo "global:
  scrape_interval: 15s
  scrape_timeout: 10s
  evaluation_interval: 15s
alerting:
  alertmanagers:
  - static_configs:
    - targets: []
    scheme: http
    timeout: 10s
    api_version: v1
scrape_configs:
- job_name: prometheus
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  static_configs:
  - targets:
    - localhost:9090" | sudo tee -a ./Containers/prometheus-grafana/prometheus/prometheus.yaml > /dev/null 

echo "Start Container for Prometheus & Grafana Machine"    
sudo docker-compose -f ./Containers/prometheus-grafana/compose.yaml up -d
sudo docker ps
