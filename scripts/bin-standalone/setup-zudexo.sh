cd /home/atri/go/src/github.com/hyperledger/fabric/build/bin

echo "Setting up env variables"

export FABRIC_CFG_PATH=/home/atri/workspace_hlf/annpurna/organizations/zudexo/conf/
export CORE_PEER_MSPCONFIGPATH=/home/atri/workspace_hlf/annpurna/organizations/zudexo/organization/peerOrganizations/zudexo.yamuna.com/peers/peer0.zudexo.yamuna.com/msp
export CORE_PEER_LOCALMSPID=ZudexoMSP
export FABRIC_LOGGING_SPEC=DEBUG
export CORE_PEER_TLS_ENABLED=true
export CORE_PEER_PROFILE_ENABLED=true
export ZUDEXO_PEER_TLS_DIR=/home/atri/workspace_hlf/annpurna/organizations/zudexo/organization/peerOrganizations/zudexo.yamuna.com/peers/peer0.zudexo.yamuna.com/tls/
export CORE_PEER_TLS_CERT_FILE=$ZUDEXO_PEER_TLS_DIR/server.crt
export CORE_PEER_TLS_KEY_FILE=$ZUDEXO_PEER_TLS_DIR/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=$ZUDEXO_PEER_TLS_DIR/ca.crt
export CORE_PEER_ID=peer0.zudexo.yamuna.com
export CORE_PEER_ADDRESS=peer0.zudexo.yamuna.com:7051
export CORE_PEER_LISTENADDRESS=0.0.0.0:7051
export CORE_PEER_CHAINCODEADDRESS=peer0.zudexo.yamuna.com:7052
export CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:7052
export CORE_PEER_GOSSIP_BOOTSTRAP=peer0.zudexo.yamuna.com:7051
export CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.zudexo.yamuna.com:7051


echo "Starting peer"

peer node start