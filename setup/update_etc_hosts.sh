#!/bin/bash
# Update /etc/hosts
source    ./manage_hosts.sh

HOSTNAME=peer0.merkaba.cooperativa.com
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=peer0.visa.cooperativa.com
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=peer0.socio1.cooperativa.com
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=peer0.santander.cooperativa.com
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=orderer.cooperativa.com
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=postgresql
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=explorer
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=ca_orderer
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=ca_merkaba
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=ca_visa
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME
HOSTNAME=ca_socio1
removehost $HOSTNAME            &> /dev/null
addhost $HOSTNAME