cd /home/atri/workspace_hlf/annpurna/scripts/fabric-daemons

echo "Setting up env variables"

export FABRIC_CFG_PATH=/home/atri/workspace_hlf/annpurna/organizations/ziggy/conf-local/
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

export CORE_LEDGER_STATE_STATEDATABASE=CouchDB
export CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=127.0.0.1:17384
# The CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME and CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD
# provide the credentials for ledger to connect to CouchDB.  The username and password must
# match the username and password set for the associated CouchDB.
export CORE_LEDGER_STATE_COUCHDBCONFIG_USERNAME=admin
export CORE_LEDGER_STATE_COUCHDBCONFIG_PASSWORD=adminpw

echo "Starting peer"

peer node start