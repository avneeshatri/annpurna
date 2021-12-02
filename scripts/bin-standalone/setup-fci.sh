cd /home/atri/workspace_hlf/annpurna/scripts/fabric-daemons

echo "Setting up env variables"

export FABRIC_CFG_PATH=/home/atri/workspace_hlf/annpurna/organizations/fci/conf-local/
export CORE_PEER_MSPCONFIGPATH=/home/atri/workspace_hlf/annpurna/organizations/fci/organization/peerOrganizations/fci.saraswati.gov/peers/peer0.fci.saraswati.gov/msp
export CORE_PEER_LOCALMSPID=FciMSP
export FABRIC_LOGGING_SPEC=DEBUG
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_PROFILE_ENABLED=true
export FCI_PEER_TLS_DIR=/home/atri/workspace_hlf/annpurna/organizations/fci/organization/peerOrganizations/fci.saraswati.gov/peers/peer0.fci.saraswati.gov/tls/
export CORE_PEER_TLS_CERT_FILE=$FCI_PEER_TLS_DIR/server.crt
export CORE_PEER_TLS_KEY_FILE=$FCI_PEER_TLS_DIR/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=$FCI_PEER_TLS_DIR/ca.crt
export CORE_PEER_ID=peer0.fci.saraswati.gov
export CORE_PEER_ADDRESS=peer0.fci.saraswati.gov:7151
export CORE_PEER_LISTENADDRESS=0.0.0.0:7151
export CORE_PEER_CHAINCODEADDRESS=peer0.fci.saraswati.gov:7152
export CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7152
export CORE_PEER_GOSSIP_BOOTSTRAP=peer0.fci.saraswati.gov:7151
export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.fci.saraswati.gov:7151


echo "Starting peer"

peer node start