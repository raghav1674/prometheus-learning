#!/usr/bin/env bash
set -e 

prometheus_server_ip=$1
node_exporter_ip=$2

sudo yum update -y 

# create group and user for prometheus
sudo groupadd --system prometheus
sudo useradd -s /sbin/nologin --system -g prometheus prometheus

# create data dir for prometheus
sudo mkdir /var/lib/prometheus
for i in rules rules.d files_sd; do sudo mkdir -p /etc/prometheus/${i};done;

# install 
curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest \
  | grep browser_download_url \
  | grep linux-amd64 \
  | cut -d '"' -f 4 \
  | wget -qi -
tar xvf prometheus-*.tar.gz
cd prometheus-*/
sudo cp prometheus promtool /usr/local/bin/
sudo cp -r prometheus.yml consoles/ console_libraries/ /etc/prometheus/ 

sudo tee /etc/prometheus/prometheus.yml  <<EOF
global: 
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.  
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.  
  scrape_timeout: 15s  # scrape_timeout is set to the global default (10s).

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['${prometheus_server_ip}:9090']

  - job_name: 'node_exporter'
    static_configs:
    - targets: ['${node_exporter_ip}:9100']
EOF

# create service file for prometheus
sudo tee /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Documentation=https://prometheus.io/docs/introduction/overview/
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=prometheus
Group=prometheus
ExecReload=/bin/kill -HUP $MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.external-url=

SyslogIdentifier=prometheus
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# set the permissions 
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chmod -R 775 /etc/prometheus/
sudo chown -R prometheus:prometheus /var/lib/prometheus/

sudo timedatectl set-timezone Asia/Kolkata

sudo firewall-cmd --add-port 9090/tcp --permanent
sudo firewall-cmd --reload  

# start the service
sudo systemctl daemon-reload
sudo systemctl start prometheus
sudo systemctl enable prometheus