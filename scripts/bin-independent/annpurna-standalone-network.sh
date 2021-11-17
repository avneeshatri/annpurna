#!/bin/bash

. /home/atri/workspace_hlf/annpurna/scripts/conf/net_deploy.cnf

# change to script bin directory
cd $SCRIPT_DIR

#Functions
#++++++++++++++++++++++++++++++++++++++++++++ Functions +++++++++++++++++++++++++++++++++++++++++++++++
function printHelp {
	echo "Arguments missing <up> <down> <ca>"
}

function generateGenesisBlock(){

	#1.2 Create Genesis Block and Update policy 
	#--------------------------------------------------------
	
	#Create genesis block
	echo "Create genesis block"
	export FABRIC_CFG_PATH=${NETWORK_CONF_DIR}
	set -x
	configtxgen -profile AnnpurnaOrdererGenesis -channelID system-channel -outputBlock ${NETWORK_CONF_DIR}/system-genesis-block/genesis.block
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
	
	#Convert genesis block to json
	echo "Conver genesis block to json"
	configtxlator proto_decode --input ${NETWORK_CONF_DIR}/system-genesis-block/genesis.block --type common.Block --output ${STG_DIR}/genesis.json
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
	
	#Update Channel Creation Policy
	echo "Update ChannelCreationPolicy of genesis json"
	policy=$(cat ${NETWORK_CONF_DIR}/ChannelCreatePolicy.json)
	
	cat ${STG_DIR}/genesis.json | jq .data.data[0].payload.data.config.channel_group.groups.Consortiums.groups.SampleConsortium.values.ChannelCreationPolicy.value="${policy}" > ${STG_DIR}/modified_genesis.json
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
	
	#Convert Updated Genesis json after modification to block
	echo "Convert genesis json to block"
	configtxlator proto_encode --input ${STG_DIR}/modified_genesis.json --type common.Block --output ${NETWORK_CONF_DIR}/system-genesis-block/genesis.block
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi


}

function createChannel(){

   #1.4 Create and Sign Channel Transaction 
	#-------------------------------
	#1.4.1 Create channel transaction
	echo "Creating channel transaction"
	export FABRIC_CFG_PATH=${NETWORK_CONF_DIR}
	export CHANNEL_NAME=annpurnachannel
	export ORDERER_CA=${ORGS_DIR}/orderer/organization/ordererOrganizations/orderer.ganga.com/orderers/orderer.ganga.com/msp/tlscacerts/tlsca.ganga.com-cert.pem
	
	set -x
	configtxgen -profile AnnpurnaWalletChannel -outputCreateChannelTx ${NETWORK_CONF_DIR}/channel-artifacts/${CHANNEL_NAME}.tx -channelID $CHANNEL_NAME
	rc=$?
	
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
	
	
	#1.4.2 Sign Channel Transaction
	#Sign Channel Transaction by FCI
	
	export FABRIC_CFG_PATH=${ORGS_DIR}/fci/conf
	export CORE_PEER_MSPCONFIGPATH=${ORGS_DIR}/fci/organization/peerOrganizations/fci.saraswati.gov/users/Admin@fci.saraswati.gov/msp
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID="FciMSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${ORGS_DIR}/fci/organization/peerOrganizations/fci.saraswati.gov/peers/peer0.fci.saraswati.gov/tls/ca.crt
	export CORE_PEER_ADDRESS=localhost:7151
	
	
	
	peer channel signconfigtx -o localhost:8051 --ordererTLSHostnameOverride orderer.ganga.com -f ${NETWORK_CONF_DIR}/channel-artifacts/${CHANNEL_NAME}.tx  --tls --cafile ${ORDERER_CA}
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
	
	#Sign Channel Transaction by Zudexo	
	
	export FABRIC_CFG_PATH=${ORGS_DIR}/zudexo/conf
	export CORE_PEER_MSPCONFIGPATH=${ORGS_DIR}/zudexo/organization/peerOrganizations/zudexo.yamuna.com/users/Admin@zudexo.yamuna.com/msp
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID="ZudexoMSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${ORGS_DIR}/zudexo/organization/peerOrganizations/zudexo.yamuna.com/peers/peer0.zudexo.yamuna.com/tls/ca.crt
	export CORE_PEER_ADDRESS=localhost:7051
	
	
	peer channel signconfigtx -o localhost:8051 --ordererTLSHostnameOverride orderer.ganga.com -f ${NETWORK_CONF_DIR}/channel-artifacts/${CHANNEL_NAME}.tx  --tls --cafile ${ORDERER_CA}
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
	
	
	#1.5 Submit Channel transaction To orderer
	#--------------------------------------------
	sleep 10s
	echo "Submitting channel transaction"
	
	export FABRIC_CFG_PATH=${ORGS_DIR}/fci/conf
	export CORE_PEER_MSPCONFIGPATH=${ORGS_DIR}/fci/organization/peerOrganizations/fci.saraswati.gov/users/Admin@fci.saraswati.gov/msp
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID="FciMSP"
	export CORE_PEER_TLS_ROOTCERT_FILE=${ORGS_DIR}/fci/organization/peerOrganizations/fci.saraswati.gov/peers/peer0.fci.saraswati.gov/tls/ca.crt
	export CORE_PEER_ADDRESS=localhost:7151
	
	peer channel create -o localhost:8051 -c $CHANNEL_NAME --ordererTLSHostnameOverride orderer.ganga.com -f ${NETWORK_CONF_DIR}/channel-artifacts/${CHANNEL_NAME}.tx --outputBlock ${NETWORK_CONF_DIR}/channel-artifacts/${CHANNEL_NAME}.block --tls --cafile ${ORDERER_CA} 
	rc=$?
	
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
}


joinChannel(){
#1.6 Join Channel
	#-------------------
	sleep 20s
	#1.6.1 Join FCI
	#------------------
	
	ORG_DOMAIN=$1
	ORG_NAME=$2
	ORG_PORT=$3
	ORG_MSPID=$4
	
	echo "Joining ${ORG_NAME} to channel"
	export FABRIC_CFG_PATH=${ORGS_DIR}/${ORG_NAME}/conf
	export CORE_PEER_MSPCONFIGPATH=${ORGS_DIR}/${ORG_NAME}/organization/peerOrganizations/${ORG_DOMAIN}/users/Admin@${ORG_DOMAIN}/msp
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID=${ORG_MSPID}
	export CORE_PEER_TLS_ROOTCERT_FILE=${ORGS_DIR}/${ORG_NAME}/organization/peerOrganizations/${ORG_DOMAIN}/peers/peer0.${ORG_DOMAIN}/tls/ca.crt
	export CORE_PEER_ADDRESS=localhost:${ORG_PORT}
	
	peer channel fetch 0 ${STG_DIR}/${CORE_PEER_LOCALMSPID}_channel.block -o localhost:8051 --ordererTLSHostnameOverride orderer.ganga.com -c $CHANNEL_NAME --tls --cafile ${ORDERER_CA}
	
	peer channel join -b ${STG_DIR}/${CORE_PEER_LOCALMSPID}_channel.block
	rc=$?
	
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
	
	peer channel  list
}

function joinOrgMemeberToChannel(){
	export CHANNEL_NAME=annpurnachannel
	export ORDERER_CA=${ORGS_DIR}/orderer/organization/ordererOrganizations/orderer.ganga.com/orderers/orderer.ganga.com/msp/tlscacerts/tlsca.ganga.com-cert.pem
	
	joinChannel "fci.saraswati.gov" "fci" "7151" "FciMSP"
	joinChannel "zudexo.yamuna.com" "zudexo" "7051" "ZudexoMSP"
	joinChannel "ziggy.bhagirathi.com" "ziggy" "7251" "ZiggyMSP"
	joinChannel "sabkabazzar.jhelum.com" "sabkabazzar" "7351" "SabkabazzarMSP"
}

function generateAnchorPeerTx(){
	#1.7 Create Anchor Peer Transaction
	#-----------------------------------
	
	#1.7.1 Shipping Anchor Peer Tx
	#----------------------------------
	echo "Generating Shipping anchor peer tx"
	
	export FABRIC_CFG_PATH=${NETWORK_CONF_DIR}
	export CHANNEL_NAME=annpurnachannel
	export orgmsp=$1
	
	configtxgen -profile AnnpurnaWalletChannel -outputAnchorPeersUpdate ${NETWORK_CONF_DIR}/channel-artifacts/${orgmsp}anchors.tx -channelID $CHANNEL_NAME -asOrg ${orgmsp}
	rc=$?
	
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
	

}

function updateChannelForAnchorPeer(){
	#1.8 Update Anchor Peer
	#------------------------------
	ORG_DOMAIN=$1
	ORG_NAME=$2
	ORG_PORT=$3
	ORG_MSPID=$4
	
	#1.8.1 Shipping Update Anchor Peer
	#--------------------------------------
	echo "Updating ${ORG_NAME} anchor peer"
	export FABRIC_CFG_PATH=${ORGS_DIR}/${ORG_NAME}/conf

	export CORE_PEER_MSPCONFIGPATH=${ORGS_DIR}/${ORG_NAME}/organization/peerOrganizations/${ORG_DOMAIN}/users/Admin@${ORG_DOMAIN}/msp
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID=${ORG_MSPID}
	export CORE_PEER_TLS_ROOTCERT_FILE=${ORGS_DIR}/${ORG_NAME}/organization/peerOrganizations/${ORG_DOMAIN}/peers/peer0.${ORG_DOMAIN}/tls/ca.crt
	export CORE_PEER_ADDRESS=localhost:${ORG_PORT}
	
	peer channel update -o localhost:8051 --ordererTLSHostnameOverride orderer.ganga.com -c $CHANNEL_NAME -f ${NETWORK_CONF_DIR}/channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls --cafile $ORDERER_CA 
	rc=$?
	
	if [[ $rc -ne 0 ]];then
		echo "Terminating process"
		exit 1
	fi
}

function anchorPeerChannelUpdate(){
	export CHANNEL_NAME=annpurnachannel
	export ORDERER_CA=${ORGS_DIR}/orderer/organization/ordererOrganizations/orderer.ganga.com/orderers/orderer.ganga.com/msp/tlscacerts/tlsca.ganga.com-cert.pem
	
	generateAnchorPeerTx "FciMSP"
	updateChannelForAnchorPeer "fci.saraswati.gov" "fci" "7151" "FciMSP"
	generateAnchorPeerTx "ZudexoMSP"
	updateChannelForAnchorPeer "zudexo.yamuna.com" "zudexo" "7051" "ZudexoMSP"
	generateAnchorPeerTx "ZiggyMSP"
	updateChannelForAnchorPeer "ziggy.bhagirathi.com" "ziggy" "7251" "ZiggyMSP"
	generateAnchorPeerTx "SabkabazzarMSP"
	updateChannelForAnchorPeer "sabkabazzar.jhelum.com" "sabkabazzar" "7351" "SabkabazzarMSP"

}
#++++++++++++++++++++++++++++++++++++++++++++++++++ Execute +++++++++++++++++++++++++++++++++++++++++++++



MODE="up"

## Parse mode
if [[ $# -lt 1 ]] ; then
  printHelp
  exit 0
fi



# parse flags

while [[ $# -ge 1 ]] ; do
  key="$1"
  case $key in
  -h )
    printHelp
    exit 0
    ;;
 -u )
    MODE="UP"
    ;;
  -d )
    MODE="DOWN"
    ;;
  -ca )
    CRYPTO="CA"
    ;;
  * )
    echo "Unknown flag: $key"
    printHelp
    exit 1
    ;;
  esac
  shift
done

echo "Mode : $MODE"
echo "CRYPTO $CRYPTO"

cd /home/atri/workspace_hlf/hlf_shipping_network/bin
sudo docker ps -a

networkDown
bringDownFabricCA
if [[ $MODE == "DOWN" ]];then
	echo "network is down"
	exit 0
fi
 

if [[ $rc -eq 0 && $MODE == "UP" ]];then	

	createChannel
	joinOrgMemeberToChannel
	anchorPeerChannelUpdate
	rc=$?
fi



if [[ $rc -eq 0 ]];then
	echo "Setup completed successfully"
else
	echo "Network setup failed"
fi
exit $rc

