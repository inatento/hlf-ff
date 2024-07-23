#!/bin/bash

# Lookup for the Fabric binaries

cd $HOME

FABRIC_BINS=$HOME/fabric-samples/bin

# Config
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Setup initiation message
echo -e "${GREEN}Iniciando la configuración de FireFly con Fabric...${NC}"
echo -e "${GREEN}Para cancelar, presiona CTRL+C.${NC}"
sleep 5

# Install prerequisites
curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh
./install-fabric.sh docker samples binary

# Check if it's OK
export PATH="$PATH:$FABRIC_BINS"
if command -v peer &> /dev/null; then
    echo -e "${GREEN}¡Los binarios de Fabric se han instalado correctamente!${NC}"
else
    echo -e "${RED}ERROR: ¡Los binarios de Fabric no se pudieron agregar correctamente al PATH!${NC}"
    exit 1
fi

# Check if it's OK
ff version
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Firefly CLI está funcionando correctamente.${NC}"
else
    echo -e "${RED}ERROR: Firefly CLI no está funcionando correctamente.${NC}"
    exit 1
fi

# Get FireFly repository
git clone https://github.com/hyperledger/firefly.git

exit 1