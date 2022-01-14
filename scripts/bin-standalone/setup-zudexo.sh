#cd /home/atri/go/src/github.com/hyperledger/fabric/build/bin
cd /home/atri/workspace_hlf/annpurna/scripts/fabric-daemons-hsm/

#Generate TLS certificates Start
export FABRIC_CA_CLIENT_HOME=/home/atri/workspace_hlf/annpurna/staging/zudexo-fabric-ca-client
export ORG_CA_TLS_PATH=/home/atri/workspace_hlf/annpurna/organizations/zudexo/fabric-ca-standalone-hsm/tls-cert.pem
rm -rf /home/atri/workspace_hlf/annpurna/staging/zudexo-fabric-ca-client/tls/
#/home/atri/workspace_hlf/annpurna/staging/zudexo-fabric-ca-client/fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-zudexo --tls.certfiles $ORG_CA_TLS_PATH
/home/atri/workspace_hlf/annpurna/staging/zudexo-fabric-ca-client/fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname  ca-zudexo -M $FABRIC_CA_CLIENT_HOME/tls --enrollment.profile tls --csr.hosts peer0.zudexo.yamuna.com --csr.hosts localhost --tls.certfiles $ORG_CA_TLS_PATH
cp /home/atri/workspace_hlf/annpurna/staging/zudexo-fabric-ca-client/tls/tlscacerts/* /home/atri/workspace_hlf/annpurna/organizations/zudexo/organization/peerOrganizations/zudexo.yamuna.com/peers/peer0.zudexo.yamuna.com/tls/ca.crt
cp /home/atri/workspace_hlf/annpurna/staging/zudexo-fabric-ca-client/tls/signcerts/* /home/atri/workspace_hlf/annpurna/organizations/zudexo/organization/peerOrganizations/zudexo.yamuna.com/peers/peer0.zudexo.yamuna.com/tls/server.crt
cp /home/atri/workspace_hlf/annpurna/staging/zudexo-fabric-ca-client/tls/keystore/* /home/atri/workspace_hlf/annpurna/organizations/zudexo/organization/peerOrganizations/zudexo.yamuna.com/peers/peer0.zudexo.yamuna.com/tls/server.key
#Generate TLS certifactes END 

echo "Setting up env variables"

export FABRIC_CFG_PATH=/home/atri/workspace_hlf/annpurna/organizations/zudexo/conf-local/
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

export CORE_LEDGER_STATE_STATEDATABASE=CouchDB
export CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=127.0.0.1:17284
# The CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME and CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD
# provide the credentials for ledger to connect to CouchDB.  The username and password must
# match the username and password set for the associated CouchDB.
export CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=admin
export CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=adminpw

echo "Starting peer"

./peer node start