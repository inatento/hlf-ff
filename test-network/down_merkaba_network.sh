#!/bin/bash

ff remove dev -f
docker-compose -f compose/compose-bft-test-net.yaml -f compose/docker/docker-compose-bft-test-net.yaml -f compose/compose-couch.yaml -f compose/docker/docker-compose-couch.yaml -f compose/compose-ca.yaml -f compose/docker/docker-compose-ca.yaml -f compose/compose-test-net.yaml -f compose/docker/docker-compose-test-net.yaml down --volumes --remove-orphans
# Bring down the network, deleting the volumes
docker volume rm docker_orderer.cooperativa.com docker_peer0.merkaba.cooperativa.com docker_peer0.visa.cooperativa.com docker_peer0.socio1.cooperativa.com
# remove orderer block and other channel configuration transactions and certs
docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf system-genesis-block/*.block organizations/peerOrganizations organizations/ordererOrganizations'
## remove fabric ca artifacts
docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/merkaba/msp organizations/fabric-ca/merkaba/tls-cert.pem organizations/fabric-ca/merkaba/ca-cert.pem organizations/fabric-ca/merkaba/IssuerPublicKey organizations/fabric-ca/merkaba/IssuerRevocationPublicKey organizations/fabric-ca/merkaba/fabric-ca-server.db'
docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/visa/msp organizations/fabric-ca/visa/tls-cert.pem organizations/fabric-ca/visa/ca-cert.pem organizations/fabric-ca/visa/IssuerPublicKey organizations/fabric-ca/visa/IssuerRevocationPublicKey organizations/fabric-ca/visa/fabric-ca-server.db'
docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/socio1/msp organizations/fabric-ca/socio1/tls-cert.pem organizations/fabric-ca/socio1/ca-cert.pem organizations/fabric-ca/socio1/IssuerPublicKey organizations/fabric-ca/socio1/IssuerRevocationPublicKey organizations/fabric-ca/socio1/fabric-ca-server.db'
docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf organizations/fabric-ca/ordererOrg/msp organizations/fabric-ca/ordererOrg/tls-cert.pem organizations/fabric-ca/ordererOrg/ca-cert.pem organizations/fabric-ca/ordererOrg/IssuerPublicKey organizations/fabric-ca/ordererOrg/IssuerRevocationPublicKey organizations/fabric-ca/ordererOrg/fabric-ca-server.db'
# remove channel and script artifacts
docker run --rm -v "$(pwd):/data" busybox sh -c 'cd /data && rm -rf channel-artifacts log.txt *.tar.gz'

echo "Removing remaining containers"
docker rm -f $(docker ps -aq --filter label=service=hyperledger-fabric) 2>/dev/null || true
docker rm -f $(docker ps -aq --filter name='dev-peer*') 2>/dev/null || true
docker kill "$(docker ps -q --filter name=ccaas)" 2>/dev/null || true
docker image rm -f $(docker images -aq --filter reference='dev-peer*') 2>/dev/null || true
docker system prune -a --volumes -f
docker network rm $(docker network ls -q)