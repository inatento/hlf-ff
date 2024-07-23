#!/bin/bash

apt update && apt upgrade -y
apt remove golang-go
apt purge golang-go
rm -rf /usr/local/go

# Paso 2: Descargar e instalar Go 1.21
wget https://golang.org/dl/go1.21.0.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz

# Paso 3: Configurar PATH
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.profile
source ~/.profile
echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc 
source ~/.bashrc