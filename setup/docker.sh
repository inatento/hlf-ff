#!/bin/bash

# Define the JSON content
json_content='{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}'

if [ -z $SUDO_USER ]
then
    echo "===== Script need to be executed with sudo ===="
    echo "Change directory to 'network/setup'"
    echo "Usage: sudo ./docker.sh"
    exit 0
fi


install_docker() {
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    apt-key fingerprint 0EBFCD88
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y "docker-ce"
    docker info
    # usermod -aG docker vagrant
    echo "======= Adding $SUDO_USER to the docker group ======="
    usermod -aG docker $SUDO_USER
    # Write the JSON content to /etc/docker/daemon.json
    echo "$json_content" | sudo tee /etc/docker/daemon.json > /dev/null
    chmod 666 /var/run/docker.sock
}



# Install docker
install_docker

service docker restart
systemctl daemon-reload
systemctl restart docker

echo "======= Configuración de espacio de memoria para los logs de Docker ===="
cat /etc/docker/daemon.json
# Installing docker compose
./compose.sh

echo "======= Done. PLEASE LOG OUT & LOG Back In ===="
echo "Then validate by executing    'docker info'   "

