cd /home/atri/workspace_hlf/annpurna/scripts/fabric-daemons

echo "Setting up env variables"

export FABRIC_CFG_PATH=/home/atri/workspace_hlf/annpurna/organizations/ziggy/conf/
export CORE_PEER_MSPCONFIGPATH=/home/atri/workspace_hlf/annpurna/organizations/ziggy/organization/peerOrganizations/ziggy.bhagirathi.com/peers/peer0.ziggy.bhagirathi.com/msp
export CORE_PEER_LOCALMSPID=ZiggyMSP
export FABRIC_LOGGING_SPEC=DEBUG
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_PROFILE_ENABLED=true
export ZIGGY_PEER_TLS_DIR=/home/atri/workspace_hlf/annpurna/organizations/ziggy/organization/peerOrganizations/ziggy.bhagirathi.com/peers/peer0.ziggy.bhagirathi.com/tls/
export CORE_PEER_TLS_CERT_FILE=$ZIGGY_PEER_TLS_DIR/server.crt
export CORE_PEER_TLS_KEY_FILE=$ZIGGY_PEER_TLS_DIR/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=$ZIGGY_PEER_TLS_DIR/ca.crt
export CORE_PEER_ID=peer0.ziggy.bhagirathi.com
export CORE_PEER_ADDRESS=peer0.ziggy.bhagirathi.com:7251
export CORE_PEER_LISTENADDRESS=0.0.0.0:7251
export CORE_PEER_CHAINCODEADDRESS=peer0.ziggy.bhagirathi.com:7252
export CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7252
export CORE_PEER_GOSSIP_BOOTSTRAP=peer0.ziggy.bhagirathi.com:7251
export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.ziggy.bhagirathi.com.com:7251


echo "Starting peer"

peer node start