#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
# test network home var targets to test-network folder
# the reason we use a var here is to accommodate scenarios
# where execution occurs from folders outside of default as $PWD, such as the test-network/addOrg3 folder.
# For setting environment variables, simple relative paths like ".." could lead to unintended references
# due to how they interact with FABRIC_CFG_PATH. It's advised to specify paths more explicitly,
# such as using "../${PWD}", to ensure that Fabric's environment variables are pointing to the correct paths.
TEST_NETWORK_HOME=${TEST_NETWORK_HOME:-${PWD}}
. ${TEST_NETWORK_HOME}/scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${TEST_NETWORK_HOME}/organizations/ordererOrganizations/cooperativa.com/tlsca/tlsca.cooperativa.com-cert.pem
export PEER0_MERKABA_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/merkaba.cooperativa.com/tlsca/tlsca.merkaba.cooperativa.com-cert.pem
export PEER0_VISA_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/visa.cooperativa.com/tlsca/tlsca.visa.cooperativa.com-cert.pem
export PEER0_SOCIO1_CA=${TEST_NETWORK_HOME}/organizations/peerOrganizations/socio1.cooperativa.com/tlsca/tlsca.socio1.cooperativa.com-cert.pem

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG = "Merkaba" ]; then
    export CORE_PEER_LOCALMSPID=MerkabaMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_MERKABA_CA
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/merkaba.cooperativa.com/users/Admin@merkaba.cooperativa.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG = "Visa" ]; then
    export CORE_PEER_LOCALMSPID=VisaMSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_VISA_CA
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/visa.cooperativa.com/users/Admin@visa.cooperativa.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG = "Socio1" ]; then
    export CORE_PEER_LOCALMSPID=Socio1MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_SOCIO1_CA
    export CORE_PEER_MSPCONFIGPATH=${TEST_NETWORK_HOME}/organizations/peerOrganizations/socio1.cooperativa.com/users/Admin@socio1.cooperativa.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" = "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
