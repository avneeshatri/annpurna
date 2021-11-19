cd /home/atri/go/src/github.com/hyperledger/fabric/build/bin

echo "Setup env variables"

export FABRIC_CFG_PATH=/home/atri/workspace_hlf/annpurna/organizations/orderer/conf/
export FABRIC_LOGGING_SPEC=DEBUG
export ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
export ORDERER_GENERAL_LISTENPORT=8051
export ORDERER_GENERAL_GENESISMETHOD=file
export ORDERER_GENERAL_GENESISFILE=/home/atri/workspace_hlf/annpurna/network/system-genesis-block/genesis.block
export ORDERER_GENERAL_LOCALMSPID=OrdererMSP
export ORDERER_GENERAL_LOCALMSPDIR=/home/atri/workspace_hlf/annpurna/organizations/orderer/organization/ordererOrganizations/orderer.ganga.com/orderers/orderer.ganga.com/msp
      # enabled TLS
export ORDERER_GENERAL_TLS_ENABLED=true
export ORDERER_TLS_DIR=/home/atri/workspace_hlf/annpurna/organizations/orderer/organization/ordererOrganizations/orderer.ganga.com/orderers/orderer.ganga.com/tls/
export ORDERER_GENERAL_TLS_PRIVATEKEY=$ORDERER_TLS_DIR/server.key
export ORDERER_GENERAL_TLS_CERTIFICATE=$ORDERER_TLS_DIR/server.crt
export ORDERER_GENERAL_TLS_ROOTCAS=[$ORDERER_TLS_DIR/ca.crt]
export ORDERER_KAFKA_TOPIC_REPLICATIONFACTOR=1
export ORDERER_KAFKA_VERBOSE=true
export ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=$ORDERER_TLS_DIR/server.crt
export ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=$ORDERER_TLS_DIR/server.key
export ORDERER_GENERAL_CLUSTER_ROOTCAS=[$ORDERER_TLS_DIR/ca.crt]

echo "Start orderer"

orderer
