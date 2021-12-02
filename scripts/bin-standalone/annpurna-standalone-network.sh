#!/bin/bash

. /home/atri/workspace_hlf/annpurna/scripts/conf/net_deploy-standalone.cnf

# change to script bin directory
cd $SCRIPT_DIR

#Functions
#++++++++++++++++++++++++++++++++++++++++++++ Functions +++++++++++++++++++++++++++++++++++++++++++++++
function init {
	echo "Performing clean up and some tweaks"
	sudo chown atri:atri -R /home/atri/workspace_hlf/annpurna/organizations
	rm -rf /tmp/hyperledger/
	mkdir /tmp/hyperledger/
}


function startNetwork {
	
	echo "Starting services of members"
	
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/orderer
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-orderer.sh &
	
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/fci
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-fci.sh &
	
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/zudexo
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-zudexo.sh &
	
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/ziggy
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-ziggy.sh &
	
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/sabkabazzar/
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-sabkabazzar.sh &

}

function startCANetwork {
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/orderer-ca
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-orderer-ca.sh &
	
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/fci-ca
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-fci-ca.sh &
	
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/zudexo-ca
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-zudexo-ca.sh &
	
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/ziggy-ca
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-ziggy-ca.sh &
	
	cd /home/atri/workspace_hlf/annpurna/scripts/logs/sabkabazzar-ca/
	nohup /home/atri/workspace_hlf/annpurna/scripts/bin-standalone/setup-sabkabazzar-ca.sh &

}


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
	
	export FABRIC_CFG_PATH=${ORGS_DIR}/fci/conf-local
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
	
	export FABRIC_CFG_PATH=${ORGS_DIR}/zudexo/conf-local
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
	
	export FABRIC_CFG_PATH=${ORGS_DIR}/fci/conf-local
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
	export FABRIC_CFG_PATH=${ORGS_DIR}/${ORG_NAME}/conf-local
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
	export FABRIC_CFG_PATH=${ORGS_DIR}/${ORG_NAME}/conf-local

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

function generateCrypto() {
	echo "Generating Zudexo crypto"
	${SCRIPT_DIR}/setUpCA.sh "zudexo.yamuna.com" ${ORGS_DIR}"/zudexo" "ca-zudexo" "7054"
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Zudexo CA Setup Failed"
		return $rc
	fi
	
	echo "Generating FCI crypto"
	${SCRIPT_DIR}/setUpCA.sh "fci.saraswati.gov" ${ORGS_DIR}"/fci" "ca-fci" "7154"
     rc=$?
     if [[ $rc -ne 0 ]];then
                echo "FCI CA Setup Failed"
                return $rc
     fi
     
    echo "Generating Ziggy crypto"
	${SCRIPT_DIR}/setUpCA.sh "ziggy.bhagirathi.com" ${ORGS_DIR}"/ziggy" "ca-ziggy" "7254"
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Ziggy CA Setup Failed"
		return $rc
	fi   
	
	echo "Generating Sabkabazzar crypto"
	${SCRIPT_DIR}/setUpCA.sh "sabkabazzar.jhelum.com" ${ORGS_DIR}"/sabkabazzar" "ca-sabkabazzar" "7354"
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Sabkabazzar CA Setup Failed"
		return $rc
	fi  
	
	echo "Generating Orderer crypto"
	${SCRIPT_DIR}/setUpOrdererCA.sh "orderer.ganga.com" ${ORGS_DIR}"/orderer" "ca-orderer" "8054"
	rc=$?
	if [[ $rc -ne 0 ]];then
		echo "Orderer CA Setup Failed"
		return $rc
	fi
}

function generateGenesisBlock {

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

function bringDownFabricCAServer {
	ps -ef | grep fabric-ca-server
	kill -9 $(ps -ef | grep fabric-ca-server | cut -d " " -f ${pid_index})
	ps -ef | grep fabric-ca-server
}

function bringDownNetworkServer {
	ps -ef | grep peer
	kill -9 $(ps -ef | grep peer | cut -d " " -f ${pid_index})
	ps -ef | grep peer
	
	ps -ef | grep orderer
	kill -9 $(ps -ef | grep orderer | cut -d " " -f ${pid_index})
	ps -ef | grep orderer
	
	ps -ef | grep "chaincode.jar"
	kill -9 $(ps -ef | grep "chaincode.jar" | cut -d " " -f ${pid_index})
	ps -ef | grep "chaincode.jar"
	
}

#++++++++++++++++++++++++++++++++++++++++++++++++++ Execute +++++++++++++++++++++++++++++++++++++++++++++

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

cd /home/atri/workspace_hlf/annpurna/scripts/bin-standalone

init

if [[ $MODE == "DOWN" ]];then
	echo "network is down"
	pid_index=8
	bringDownNetworkServer
	bringDownFabricCAServer
	exit 0
fi

if [[ $CRYPTO == "CA" ]];then
	echo "generate crypto"
	startCANetwork
	sleep 10s
	generateCrypto
	rc=$?
fi

if [[ $rc -eq 0 && $MODE == "UP" ]];then	
	generateGenesisBlock
	startNetwork
	sleep 10s
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

