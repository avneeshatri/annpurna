#!/bin/bash

seq=$1
vs=$2
if [[ -z $seq || -z $vs ]];then
	echo "Sequence of Version missing"
	exit 1
fi

#AND ( AND ('ZudexoMSP.member', 'FciMSP.member'), OR('FciMSP.member','ZudexoMSP.member','Ziggy.member', 'SabkabazzarMSP.member'))
#OutOf(3,'FciMSP.member','ZudexoMSP.member','Ziggy.member', 'SabkabazzarMSP.member')

signature_policy="AND ( AND ('ZudexoMSP.member', 'FciMSP.member'), OR('FciMSP.member','ZudexoMSP.member','Ziggy.member', 'SabkabazzarMSP.member'))"

. /home/atri/workspace_hlf/annpurna/scripts/conf/net_deploy.cnf
	
cdir=$CC_DIR
echo "Clean up chaincode dir"
rm -rf $cdir/*
cd  $cdir
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++Function +++++++++++++++++++++++++++++++++++++++++++
function approveChaincode {
		
		PACKAGE_ID=$(peer lifecycle chaincode queryinstalled | grep custom_${vs} | grep -oP '(?<=Package ID: ).*?(?=,)')
		echo "PackageID: $PACKAGE_ID"
		
		export CC_PACKAGE_ID=$PACKAGE_ID
		peer lifecycle chaincode approveformyorg -o localhost:8051 --ordererTLSHostnameOverride ${ORDERER_HOST} --channelID $CHANNEL_NAME --signature-policy "${signature_policy}" --name $CHAINCODE_NAME --version ${vs} --package-id $CC_PACKAGE_ID --sequence ${seq} --tls --cafile ${ORDERER_CA}
		rc=$?
	
		if [[ $rc -ne 0 ]];then
			echo "Terminating process"
			exit 1
		fi

}

#Package Install Custom Chaincode
#-------------------------------------

function packageInstall() {
		ORG_DOMAIN=$1
		ORG_NAME=$2
		ORG_PORT=$3
		ORG_MSPID=$4
	
		export FABRIC_CFG_PATH=${ORGS_DIR}/${ORG_NAME}/conf
		export CORE_PEER_MSPCONFIGPATH=${ORGS_DIR}/${ORG_NAME}/organization/peerOrganizations/${ORG_DOMAIN}/users/Admin@${ORG_DOMAIN}/msp
		export CORE_PEER_TLS_ENABLED=true
		export CORE_PEER_LOCALMSPID=${ORG_MSPID}
		export CORE_PEER_TLS_ROOTCERT_FILE=${ORGS_DIR}/${ORG_NAME}/organization/peerOrganizations/${ORG_DOMAIN}/peers/peer0.${ORG_DOMAIN}/tls/ca.crt
		export CORE_PEER_ADDRESS=localhost:${ORG_PORT}
		
		echo "Package ${ORG_NAME} Chain Code"
		peer lifecycle chaincode package custom_${vs}.tar.gz --path /home/atri/workspace_hlf/annpurna-wallet --lang java --label custom_${vs}
		rc=$?
	
		if [[ $rc -ne 0 ]];then
			echo "Terminating process"
			exit 1
		fi
				
		echo "Install Chaincode for ${ORG_NAME} "
		peer lifecycle chaincode install custom_${vs}.tar.gz
		rc=$?
	
		if [[ $rc -ne 0 ]];then
			echo "Terminating process"
			exit 1
		fi
				
		peer lifecycle chaincode queryinstalled
		rc=$?
	
		if [[ $rc -ne 0 ]];then
			echo "Terminating process"
			exit 1
		fi
				
		echo "Approve Chaincode for ${ORG_NAME} "
		approveChaincode
		rc=$?
	
		if [[ $rc -ne 0 ]];then
			echo "Terminating process"
			exit 1
		fi
}

function packageInstallForMembers(){
	packageInstall "zudexo.yamuna.com" "zudexo" "7051" "ZudexoMSP"
	packageInstall "fci.saraswati.gov" "fci" "7151" "FciMSP"
	packageInstall "ziggy.bhagirathi.com" "ziggy" "7251" "ZiggyMSP"
	packageInstall "sabkabazzar.jhelum.com" "sabkabazzar" "7351" "SabkabazzarMSP"

}

#Commit Readiness Status
#----------------------------
function checkCommitRediness(){
	echo "Checking commit readiness"
	peer lifecycle chaincode checkcommitreadiness --signature-policy "${signature_policy}" --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version ${vs} --sequence ${seq} --tls --cafile $ORDERER_CA
	rc=$?
	
	if [[ $rc -ne 0 ]];then
			echo "Terminating process"
			exit 1
	fi
}
#Commit Chaincode
#------------------------------
function commitChaincode(){
	echo "Commit chain code as Zudexo ORG"
	
	export FABRIC_CFG_PATH=${ORGS_DIR}/zudexo/conf
	export CORE_PEER_MSPCONFIGPATH=${ORGS_DIR}/zudexo/organization/peerOrganizations/zudexo.yamuna.com/users/Admin@zudexo.yamuna.com/msp
	export CORE_PEER_TLS_ENABLED=true
	export CORE_PEER_LOCALMSPID="ZudexoMSP"
	
	
	export ZUDEXO_PEER_TLS_ROOTCERT_FILE=${ORGS_DIR}/zudexo/organization/peerOrganizations/zudexo.yamuna.com/peers/peer0.zudexo.yamuna.com/tls/ca.crt
	export ZUDEXO_PEER_ADDRESS=localhost:7051
	
	export FCI_PEER_TLS_ROOTCERT_FILE=${ORGS_DIR}/fci/organization/peerOrganizations/fci.saraswati.gov/peers/peer0.fci.saraswati.gov/tls/ca.crt
	export FCI_PEER_ADDRESS=localhost:7151
	
	
	export ZIGGY_PEER_TLS_ROOTCERT_FILE=${ORGS_DIR}/ziggy/organization/peerOrganizations/ziggy.bhagirathi.com/peers/peer0.ziggy.bhagirathi.com/tls/ca.crt
	export ZIGGY_PEER_ADDRESS=localhost:7251
	
	
	peer lifecycle chaincode commit --signature-policy "${signature_policy}" -o localhost:8051 --ordererTLSHostnameOverride orderer.ganga.com --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --version ${vs} --sequence ${seq} --tls --cafile $ORDERER_CA --peerAddresses $ZUDEXO_PEER_ADDRESS --tlsRootCertFiles $ZUDEXO_PEER_TLS_ROOTCERT_FILE --peerAddresses $FCI_PEER_ADDRESS --tlsRootCertFiles $FCI_PEER_TLS_ROOTCERT_FILE --peerAddresses $ZIGGY_PEER_ADDRESS --tlsRootCertFiles $ZIGGY_PEER_TLS_ROOTCERT_FILE 
	rc=$?
	
		if [[ $rc -ne 0 ]];then
			echo "Terminating process"
			exit 1
		fi
	# Query Chain code status on Channle
	#----------------------------------------
	
	echo "Chain code status on channel"
	
	peer lifecycle chaincode querycommitted --channelID $CHANNEL_NAME --name $CHAINCODE_NAME --cafile $ORDERER_CA
	rc=$?
	
	if [[ $rc -ne 0 ]];then
			echo "Terminating process"
			exit 1
	fi
}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++ Execute ++++++++++++++++++++++++++++++++++++++++++
echo "Start chaincode installation"

packageInstallForMembers
checkCommitRediness
commitChaincode

echo "Chaincode Installation Complete"