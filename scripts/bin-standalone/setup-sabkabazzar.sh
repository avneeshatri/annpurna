cd /home/atri/workspace_hlf/annpurna/scripts/fabric-daemons

echo "Setting up env variables"

export FABRIC_CFG_PATH=/home/atri/workspace_hlf/annpurna/organizations/sabkabazzar/conf-local/
export CORE_PEER_MSPCONFIGPATH=/home/atri/workspace_hlf/annpurna/organizations/sabkabazzar/organization/peerOrganizations/sabkabazzar.jhelum.com/peers/peer0.sabkabazzar.jhelum.com/msp
export CORE_PEER_LOCALMSPID=SabkabazzarMSP
export FABRIC_LOGGING_SPEC=DEBUG
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_PROFILE_ENABLED=true
export SABKABAZZAR_PEER_TLS_DIR=/home/atri/workspace_hlf/annpurna/organizations/sabkabazzar/organization/peerOrganizations/sabkabazzar.jhelum.com/peers/peer0.sabkabazzar.jhelum.com/tls/
export CORE_PEER_TLS_CERT_FILE=$SABKABAZZAR_PEER_TLS_DIR/server.crt
export CORE_PEER_TLS_KEY_FILE=$SABKABAZZAR_PEER_TLS_DIR/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=$SABKABAZZAR_PEER_TLS_DIR/ca.crt
export CORE_PEER_ID=peer0.sabkabazzar.jhelum.com
export CORE_PEER_ADDRESS=peer0.sabkabazzar.jhelum.com:7351
export CORE_PEER_LISTENADDRESS=0.0.0.0:7351
export CORE_PEER_CHAINCODEADDRESS=peer0.sabkabazzar.jhelum.com:7352
export CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7352
export CORE_PEER_GOSSIP_BOOTSTRAP=peer0.sabkabazzar.jhelum.com:7351
export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.sabkabazzar.jhelum.com:7351


echo "Starting peer"

peer node start