#!/bin/bash

# Lookup for the Fabric binaries

cd $HOME

FABRIC_TEST_NETWORK="$PWD/fabric-samples/test-network"
ORGANIZATIONS="$FABRIC_TEST_NETWORK/organizations"
ORG1_USER_KEYSTORE_DIR="$ORGANIZATIONS/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/"
ORG2_USER_KEYSTORE_DIR="$ORGANIZATIONS/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/keystore/"
FABRIC_BINS=$PWD/fabric-samples/bin

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

cd fabric-samples/test-network
sudo chmod +x network.sh
./network.sh down
sleep 1
./network.sh up createChannel -ca

# Deploy FireFly Chaincode
echo -e "${GREEN}Empezando deploy del smart contract de firefly${NC}"

cd ../../firefly/smart_contracts/fabric/firefly-go
GO111MODULE=on go mod vendor
cd ../../../../hlf-ff/test-network

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

peer lifecycle chaincode package firefly.tar.gz --path ../../firefly/smart_contracts/fabric/firefly-go --lang golang --label firefly_1.0

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer lifecycle chaincode install firefly.tar.gz

export CORE_PEER_LOCALMSPID="Org2MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer lifecycle chaincode install firefly.tar.gz

export CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq --raw-output ".installed_chaincodes[0].package_id")

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name firefly --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

export CORE_PEER_LOCALMSPID="Org1MSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051

peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name firefly --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.example.com --channelID mychannel --name firefly --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt"

# Getting CCP Templates
cd $HOME
curl -sSLO https://raw.githubusercontent.com/JoseOrd/deploy-firefly-with-fabric/master/org1_ccp.yml
curl -sSLO https://raw.githubusercontent.com/JoseOrd/deploy-firefly-with-fabric/master/org2_ccp.yml

# Print keystore keys
echo -e "${GREEN}Por favor, reemplace la cadena FILL_IN_KEY_NAME_HERE con estas claves (SÓLO LA CLAVE) en org1_ccp.yml y org2_ccp.yml${NC}"
echo -e "${YELLOW}Org1 Key: $(ls "$ORG1_USER_KEYSTORE_DIR")${NC}"
echo -e "${YELLOW}Org2 Key: $(ls "$ORG2_USER_KEYSTORE_DIR")${NC}"

# Waiting the user for key replacement
read -p "Estoy esperando... ¿Ha realizado el reemplazo? (y/N) " answer
if [[ $answer == "y" ]]; then
    echo -e "${GREEN}IN PROGRESS...${NC}"
else
    echo -e "${RED}ERROR: I cannot go on!${NC}"
    exit 1
fi

# Stop and remove dev stack on FireFly if it is exist
cd $FABRIC_TEST_NETWORK
ff stop dev
echo "y" | ff remove dev

# Initialization FireFly Fabric stack as dev
sudo chmod -R 777 $FABRIC_TEST_NETWORK
cd $FABRIC_TEST_NETWORK

ff init fabric dev \
    --ccp "${HOME}/org1_ccp.yml" \
    --msp "organizations" \
    --ccp "${HOME}/org2_ccp.yml" \
    --msp "organizations" \
    --ccp "${HOME}/org3_ccp.yml" \
    --msp "organizations" \
    --channel cooperativa \
    --chaincode firefly

ff init fabric dev \
    --ccp "${HOME}/org1_ccp.yml" \
    --msp "organizations" \
    --ccp "${HOME}/org2_ccp.yml" \
    --msp "organizations" \
    --channel cooperativa \
    --chaincode firefly

# Replace docker-compose.override.yml with edited version
echo -e "${GREEN}Realizando la configuracion...${NC}"

cd $HOME/.firefly/stacks/dev/
sudo rm docker-compose.override.yml
curl -sSLO https://raw.githubusercontent.com/JoseOrd/deploy-firefly-with-fabric/master/docker-compose.override.yml

sudo rm docker-compose.yml
curl -sSLO https://raw.githubusercontent.com/JoseOrd/deploy-firefly-with-fabric/master/docker-compose.yml

# Starting message
echo -e "${GREEN}Si todo parece estar bien, la pila de FireFly comenzará en 5 segundos.${NC}"
sleep 5

# Start FireFly Fabric stack that named dev
ff start dev --verbose --no-rollback

exit 1