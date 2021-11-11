#!/bin/bash

#+++++++++++++++++++++++++++++++++++++++ Functions ++++++++++++++++++++++++++++++++++++++++++++++++++ 


function initSetup() {
	echo "############################ Set Up Fabric CA Client #############################"
	export ORG_DOMAIN=${domain_name}
	export ORG_CA_PORT=${ca_port}
	export ORG_BASE_DIR=${base_path}
	export FABRIC_CA_CLIENT_HOME=${ORG_BASE_DIR}/organization/peerOrganizations/${ORG_DOMAIN}/
	export CA_NAME=${ca_name}
	export ORG_CA_PATH=${ORG_BASE_DIR}/fabric-ca
	export ORG_CA_TLS_PATH=${ORG_CA_PATH}/tls-cert.pem
	
	
	echo "############################ Delete existing setup files##########################"
#	sudo rm -rf ${ORG_CA_PATH}
#	mkdir ${ORG_CA_PATH}
	
	sudo rm -rf ${FABRIC_CA_CLIENT_HOME}
	mkdir ${FABRIC_CA_CLIENT_HOME}
	
	echo "############################################ Create Org Config #####################"
	mkdir -p $FABRIC_CA_CLIENT_HOME/msp
	
	echo "NodeOUs:
      Enable: true
      ClientOUIdentifier:
        Certificate: cacerts/localhost-${ORG_CA_PORT}-${CA_NAME}.pem
        OrganizationalUnitIdentifier: client
      PeerOUIdentifier:
        Certificate: cacerts/localhost-${ORG_CA_PORT}-${CA_NAME}.pem
        OrganizationalUnitIdentifier: peer
      AdminOUIdentifier:
        Certificate: cacerts/localhost-${ORG_CA_PORT}-${CA_NAME}.pem
        OrganizationalUnitIdentifier: admin
      OrdererOUIdentifier:
        Certificate: cacerts/localhost-${ORG_CA_PORT}-${CA_NAME}.pem
        OrganizationalUnitIdentifier: orderer" > $FABRIC_CA_CLIENT_HOME/msp/config.yaml
        rc=$?
	    
	    return $rc
}


function register() {
      echo "################################### Register Users(Peer/User/Admin) ###############################"
 
      mkdir -p $FABRIC_CA_CLIENT_HOME
	
	  fabric-ca-client enroll -u https://admin:adminpw@localhost:${ORG_CA_PORT} --caname $CA_NAME --tls.certfiles $ORG_CA_TLS_PATH
      rc=$?
        
      if [[ $rc -eq 0 ]];then
 	  	
	  
	  	registerFabricCAClient peer0 peer0pw peer
		rc=$?
		
		if [[ $rc -ne 0 ]];then
			return $rc
		fi
		
	  	registerFabricCAClient user1 user1pw client
		rc=$?
		
		if [[ $rc -ne 0 ]];then
			return $rc
		fi
		
	  	registerFabricCAClient orgadmin orgadminpw admin
	  	rc=$?
	  	
	  	if [[ $rc -ne 0 ]];then
			return $rc
		fi
	  			
	  fi
	  
	  return $rc
}

function registerFabricCAClient() {

	output=$(fabric-ca-client identity list --caname $CA_NAME  --tls.certfiles $ORG_CA_TLS_PATH | grep $1)
	
	if [[ ! -z ${output} ]];then
		echo "$1 already registered"
		return 0
	fi
	
	echo "Register $1"
	fabric-ca-client register --caname $CA_NAME --id.name $1 --id.secret $2 --id.type $3 --tls.certfiles $ORG_CA_TLS_PATH
	rc=$?
	
	return $rc
}

 
function generatePeerTls() {

  echo "################# Generate Peer TLS Certifciates #############################"

  mkdir -p $FABRIC_CA_CLIENT_HOME/peers
  mkdir -p $FABRIC_CA_CLIENT_HOME/peers/peer0.${ORG_DOMAIN}

  export PEER_HOST=peer0.${ORG_DOMAIN}
  export PEER_ID_CFG_PATH=$FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST

  echo "Generate the peer0 msp"
  
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:${ORG_CA_PORT} --caname $CA_NAME -M $PEER_ID_CFG_PATH/msp --csr.hosts $PEER_HOST --tls.certfiles $ORG_CA_TLS_PATH
  rc=$?
  
  if [[ $rc -ne 0 ]];then
  	echo "Peer MSP Generation failed"
  	return $rc
  fi

  cp $FABRIC_CA_CLIENT_HOME/msp/config.yaml $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/msp/config.yaml

  echo "Generate the peer0-tls certificates"
  
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:${ORG_CA_PORT} --caname $CA_NAME -M $PEER_ID_CFG_PATH/tls --enrollment.profile tls --csr.hosts $PEER_HOST --csr.hosts localhost --tls.certfiles $ORG_CA_TLS_PATH
  rc=$?
  
  if [[ $rc -ne 0 ]];then
  	echo "Peer TLS Generation failed"
  	return $rc
  fi
  
  return $rc


}

function updateMSPTlsCrts() {
    ################################### Copy Generated Certificates ########################## 
	cp $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/tls/tlscacerts/* $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/tls/ca.crt
	cp $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/tls/signcerts/* $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/tls/server.crt
	
	cp $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/tls/keystore/* $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/tls/server.key
	
	mkdir -p $FABRIC_CA_CLIENT_HOME/msp/tlscacerts
	
	cp $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/tls/tlscacerts/* $FABRIC_CA_CLIENT_HOME/msp/tlscacerts/ca.crt
	
	
	mkdir -p $FABRIC_CA_CLIENT_HOME/tlsca
	cp $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/tls/tlscacerts/* $FABRIC_CA_CLIENT_HOME/tlsca/tlsca.${ORG_DOMAIN}-cert.pem
	
	mkdir -p $FABRIC_CA_CLIENT_HOME/ca
	cp $FABRIC_CA_CLIENT_HOME/peers/$PEER_HOST/msp/cacerts/* $FABRIC_CA_CLIENT_HOME/ca/ca.${ORG_DOMAIN}-cert.pem

}

function generateUserMsp() {
		echo "######################### Generating User MSP #################################"
		
		mkdir -p $FABRIC_CA_CLIENT_HOME/users
		mkdir -p $FABRIC_CA_CLIENT_HOME/users/User1@${ORG_DOMAIN}
		
		 echo "Generate the user msp"
		 set -x
		 fabric-ca-client enroll -u https://user1:user1pw@localhost:${ORG_CA_PORT} --caname $CA_NAME -M $FABRIC_CA_CLIENT_HOME/users/User1@${ORG_DOMAIN}/msp --tls.certfiles $ORG_CA_TLS_PATH
		  { set +x; } 2>/dev/null
		
		cp $FABRIC_CA_CLIENT_HOME/msp/config.yaml $FABRIC_CA_CLIENT_HOME/users/User1@${ORG_DOMAIN}/msp/config.yaml

}

function generateAdminMsp() {
  echo "####################################### Generating Admin MSP ##############################"

  echo "Generate the org admin msp"
  mkdir -p $FABRIC_CA_CLIENT_HOME/users/Admin@${ORG_DOMAIN}
  set -x
  fabric-ca-client enroll -u https://orgadmin:orgadminpw@localhost:${ORG_CA_PORT} --caname $CA_NAME -M $FABRIC_CA_CLIENT_HOME/users/Admin@${ORG_DOMAIN}/msp --csr.hosts $PEER_HOST  --tls.certfiles $ORG_CA_TLS_PATH
  { set +x; } 2>/dev/null

  cp $FABRIC_CA_CLIENT_HOME/msp/config.yaml $FABRIC_CA_CLIENT_HOME/users/Admin@${ORG_DOMAIN}/msp/config.yaml
}

#+++++++++++++++++++++++++++++++++++++++++ Execute +++++++++++++++++++++++++++++++++++++++++++++++++
domain_name=$1
base_path=$2
ca_name=$3
ca_port=$4

if [[ -z $domain_name || -z $base_path || -z $ca_name || -z $ca_port ]];then
	echo "Missing mandatory argument <domain-name> <base-path> <ca-name> <ca_port>"
	exit 1
fi

initSetup
rc=$?

if [[ $rc -eq 0 ]];then
	register
	rc=$?
fi


if [[ $rc -eq 0 ]];then
	generatePeerTls
	rc=$?
fi

if [[ $rc -eq 0 ]];then
	updateMSPTlsCrts
	rc=$?
fi

if [[ $rc -eq 0 ]];then
	generateUserMsp
	rc=$?
fi

if [[ $rc -eq 0 ]];then
	generateAdminMsp
	rc=$?
fi

if [[ $rc -eq 0 ]];then
	echo "generate artifacts"
else
	echo "Failed to generate certificates"
fi 

exit $rc
