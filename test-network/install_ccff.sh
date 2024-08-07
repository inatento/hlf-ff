#!/bin/bash

CHANNEL_NAME="cooperativa"
FABRIC_TEST_NETWORK="$HOME/hlf-ff/test-network"
ORGANIZATIONS="$FABRIC_TEST_NETWORK/organizations"
ORG1_USER_KEYSTORE_DIR=$ORGANIZATIONS/peerOrganizations/merkaba.${CHANNEL_NAME}.com/users/Admin@merkaba.${CHANNEL_NAME}.com/msp/keystore/
ORG2_USER_KEYSTORE_DIR=$ORGANIZATIONS/peerOrganizations/visa.${CHANNEL_NAME}.com/users/Admin@visa.${CHANNEL_NAME}.com/msp/keystore/
ORG3_USER_KEYSTORE_DIR=$ORGANIZATIONS/peerOrganizations/socio1.${CHANNEL_NAME}.com/users/Admin@socio1.${CHANNEL_NAME}.com/msp/keystore/
FABRIC_BINS=$PWD/fabric-samples/bin

# Define the JSON content
dc_override='# Add custom config overrides here
# See https://docs.docker.com/compose/extends
version: "2.1"
networks:
  default:
    name: cooperativa
    external: true'

# Config
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Deploy FireFly Chaincode
echo -e "${GREEN}Empezando deploy del smart contract de firefly${NC}"

cd ../../firefly/smart_contracts/fabric/firefly-go
  set -x
    GO111MODULE=on go mod vendor
    res=$?
   { set +x; } 2>/dev/null
    if [ $res -ne 0 ]; then
        echo -e "${RED}No se pudieron instalar dependencias de chaincode${NC}"
    fi
cd ../../../../hlf-ff/test-network

export PATH=${PWD}/../bin:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

set -x
    peer lifecycle chaincode package firefly.tar.gz --path ../../firefly/smart_contracts/fabric/firefly-go --lang golang --label firefly_1.0
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}Fallo al empaquetar el chaincode${NC}"
fi

export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_LOCALMSPID="MerkabaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/merkaba.${CHANNEL_NAME}.com/peers/peer0.merkaba.${CHANNEL_NAME}.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/merkaba.${CHANNEL_NAME}.com/users/Admin@merkaba.${CHANNEL_NAME}.com/msp
export CORE_PEER_ADDRESS=localhost:7051

echo -e "${GREEN}${CORE_PEER_LOCALMSPID}${NC}"
set -x
    peer lifecycle chaincode install firefly.tar.gz
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}Fallo al instalar el chaincode${NC}"
fi

export CORE_PEER_LOCALMSPID="VisaMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/visa.${CHANNEL_NAME}.com/peers/peer0.visa.${CHANNEL_NAME}.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/visa.${CHANNEL_NAME}.com/users/Admin@visa.${CHANNEL_NAME}.com/msp
export CORE_PEER_ADDRESS=localhost:9051


echo -e "${GREEN}${CORE_PEER_LOCALMSPID}${NC}"
set -x
    peer lifecycle chaincode install firefly.tar.gz
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}Fallo al instalar el chaincode${NC}"
fi

export CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq --raw-output ".installed_chaincodes[0].package_id")

set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.${CHANNEL_NAME}.com --channelID ${CHANNEL_NAME} --name firefly --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/${CHANNEL_NAME}.com/orderers/orderer.${CHANNEL_NAME}.com/msp/tlscacerts/tlsca.${CHANNEL_NAME}.com-cert.pem"
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}Fallo al instalar el chaincode${NC}"
fi


export CORE_PEER_LOCALMSPID="Socio1MSP"
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/socio1.${CHANNEL_NAME}.com/peers/peer0.socio1.${CHANNEL_NAME}.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/socio1.${CHANNEL_NAME}.com/users/Admin@socio1.${CHANNEL_NAME}.com/msp
export CORE_PEER_ADDRESS=localhost:8051

echo -e "${GREEN}${CORE_PEER_LOCALMSPID}${NC}"
set -x
    peer lifecycle chaincode install firefly.tar.gz
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}Fallo al instalar el chaincode${NC}"
fi

export CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled --output json | jq --raw-output ".installed_chaincodes[0].package_id")

set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.${CHANNEL_NAME}.com --channelID ${CHANNEL_NAME} --name firefly --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/${CHANNEL_NAME}.com/orderers/orderer.${CHANNEL_NAME}.com/msp/tlscacerts/tlsca.${CHANNEL_NAME}.com-cert.pem"
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}Fallo en aprovación de chaincode${NC}"
fi

export CORE_PEER_LOCALMSPID="MerkabaMSP"
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/merkaba.${CHANNEL_NAME}.com/users/Admin@merkaba.${CHANNEL_NAME}.com/msp
export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/merkaba.${CHANNEL_NAME}.com/peers/peer0.merkaba.${CHANNEL_NAME}.com/tls/ca.crt
export CORE_PEER_ADDRESS=localhost:7051

echo -e "${GREEN}${CORE_PEER_LOCALMSPID}${NC}"
set -x
    peer lifecycle chaincode approveformyorg -o localhost:7050 --ordererTLSHostnameOverride orderer.${CHANNEL_NAME}.com --channelID ${CHANNEL_NAME} --name firefly --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/${CHANNEL_NAME}.com/orderers/orderer.${CHANNEL_NAME}.com/msp/tlscacerts/tlsca.${CHANNEL_NAME}.com-cert.pem"
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}Fallo en la aprovación de chaincode${NC}"
fi

set -x
    peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.${CHANNEL_NAME}.com --channelID ${CHANNEL_NAME} --name firefly --version 1.0 --sequence 1 --tls --cafile "${PWD}/organizations/ordererOrganizations/${CHANNEL_NAME}.com/orderers/orderer.${CHANNEL_NAME}.com/msp/tlscacerts/tlsca.${CHANNEL_NAME}.com-cert.pem" --peerAddresses localhost:7051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/merkaba.${CHANNEL_NAME}.com/peers/peer0.merkaba.${CHANNEL_NAME}.com/tls/ca.crt" --peerAddresses localhost:9051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/visa.${CHANNEL_NAME}.com/peers/peer0.visa.${CHANNEL_NAME}.com/tls/ca.crt" --peerAddresses localhost:8051 --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/socio1.${CHANNEL_NAME}.com/peers/peer0.socio1.${CHANNEL_NAME}.com/tls/ca.crt"
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}Fallo en commit de chaincode${NC}"
fi

# Print keystore keys
echo -e "${GREEN}Por favor, reemplace la cadena FILL_IN_KEY_NAME_HERE con estas claves (SÓLO LA CLAVE) en org1_ccp.yml y org2_ccp.yml${NC}"
echo -e "${YELLOW}Org1 Key: $(ls "$ORG1_USER_KEYSTORE_DIR")${NC}"
echo -e "${YELLOW}Org2 Key: $(ls "$ORG2_USER_KEYSTORE_DIR")${NC}"
echo -e "${YELLOW}Org3 Key: $(ls "$ORG3_USER_KEYSTORE_DIR")${NC}"

read -p "Estoy esperando... ¿Ha realizado el reemplazo? (y/N) " answer
if [[ $answer == "y" ]]; then
    echo -e "${GREEN}IN PROGRESS...${NC}"
else
    echo -e "${RED}ERROR: I cannot go on!${NC}"
    exit 1
fi

# Stop and remove dev stack on FireFly if it is exist
# cd $FABRIC_TEST_NETWORK
# echo -e "${YELLOW}Se va a detener la pila dev${NC}"
# ff remove dev -f

# Initialization FireFly Fabric stack as dev
sudo chmod -R 777 $FABRIC_TEST_NETWORK
cd $FABRIC_TEST_NETWORK

# # Se va a generar sólo una conexión con un sólo perfil para probar
echo -e "${YELLOW}Inicializando la pila dev con firefly${NC}"
set -x
    ff init fabric dev \
        --ccp "$FABRIC_TEST_NETWORK/connection-profiles/org1_ccp.yml" \
        --msp "organizations" \
        --channel $CHANNEL_NAME \
        --chaincode firefly
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}No se pudo inicializar la pila dev${NC}"
fi

# # Esto sería completo:
# # ff init fabric dev \
# #     --ccp "${HOME}/org1_ccp.yml" \
# #     --msp "organizations" \
# #     --ccp "${HOME}/org2_ccp.yml" \
# #     --msp "organizations" \
# #     --ccp "${HOME}/org3_ccp.yml" \
# #     --msp "organizations" \
# #     --channel ${CHANNEL_NAME} \
# #     --chaincode firefly

echo "$dc_override" | sudo tee /home/tesseract/.firefly/stacks/dev/docker-compose.override.yml > /dev/null

# # Starting message
# echo -e "${GREEN}Si todo parece estar bien, la pila de FireFly comenzará en 5 segundos.${NC}"
# sleep 5

# Start FireFly Fabric stack that named dev
echo -e "${YELLOW}Arrancando la pila dev de firefly${NC}"
set -x
    ff start dev --verbose --no-rollback
res=$?
{ set +x; } 2>/dev/null
if [ $res -ne 0 ]; then
    echo -e "${RED}No se pudo cargar la pila dev${NC}"
fi