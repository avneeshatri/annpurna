#!/bin/bash

cd /home/atri/workspace_hlf/annpurna/scripts/fabric-daemons

#+++++++++++++++++++++++++++++++++++++++++++++++ Functions +++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function initSetup() {
	echo "############################ Set Up Fabric CA Client #############################"
	export ORG_DOMAIN=${domain_name}
	export ORG_CA_PORT=${ca_port}
	export ORG_BASE_DIR=${base_path}
	export FABRIC_CA_CLIENT_HOME=${ORG_BASE_DIR}/organization/ordererOrganizations/${ORG_DOMAIN}/
	export CA_NAME=${ca_name}
	export ORG_CA_PATH=${ORG_BASE_DIR}/fabric-ca-standalone
	export ORG_CA_TLS_PATH=${ORG_CA_PATH}/tls-cert.pem
	
	echo "############################ Delete existing setup files##########################"
	
	rm -rf ${FABRIC_CA_CLIENT_HOME}
	mkdir ${FABRIC_CA_CLIENT_HOME}
	
	echo "############################################ Create Orderer Config #####################"
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
	
	  ./fabric-ca-client enroll -u https://admin:adminpw@localhost:${ORG_CA_PORT} --caname $CA_NAME --tls.certfiles $ORG_CA_TLS_PATH
      rc=$?
        
      if [[ $rc -eq 0 ]];then
 	  	
	  
	  	registerFabricCAClient orderer ordererpw orderer
		rc=$?
		
		if [[ $rc -ne 0 ]];then
			return $rc
		fi
		
	  	registerFabricCAClient ordererAdmin ordererAdminpw admin
		rc=$?
		
		if [[ $rc -ne 0 ]];then
			return $rc
		fi
	  			
	  fi
	  
	  return $rc
}

function registerFabricCAClient() {

	output=$(./fabric-ca-client identity list --caname $CA_NAME  --tls.certfiles $ORG_CA_TLS_PATH | grep $1)
	
	if [[ ! -z ${output} ]];then
		echo "$1 already registered"
		return 0
	fi
	
	echo "Register $1"
	./fabric-ca-client register --caname $CA_NAME --id.name $1 --id.secret $2 --id.type $3 --tls.certfiles $ORG_CA_TLS_PATH
	rc=$?
	
	return $rc
}

function generateMSP(){
	./fabric-ca-client enroll -u https://orderer:ordererpw@localhost:${ORG_CA_PORT}  --caname $CA_NAME -M ${FABRIC_CA_CLIENT_HOME}"/orderers/"${ORG_DOMAIN}"/msp/" --csr.hosts ${ORG_DOMAIN} --csr.hosts localhost --tls.certfiles ${ORG_CA_TLS_PATH}
  { set +x; } 2>/dev/null

  cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/msp/config.yaml

}

function generateAdminMSP(){  
  echo "Generating the admin msp"
  set -x
  ./fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:${ORG_CA_PORT}  --caname $CA_NAME -M ${FABRIC_CA_CLIENT_HOME}/users/Admin@${ORG_DOMAIN}/msp --tls.certfiles ${ORG_CA_TLS_PATH}
  { set +x; } 2>/dev/null

  cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/users/Admin@${ORG_DOMAIN}/msp/config.yaml
}

function generateTls(){

  echo "Generating the orderer-tls certificates"
  set -x
  ./fabric-ca-client enroll -u https://orderer:ordererpw@localhost:${ORG_CA_PORT} --caname ca-orderer -M "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/tls" --enrollment.profile tls --csr.hosts ${ORG_DOMAIN} --csr.hosts localhost --tls.certfiles ${ORG_CA_TLS_PATH}
  { set +x; } 2>/dev/null
   cp "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/tls/tlscacerts/"* "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/tls/ca.crt"
  cp "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/tls/signcerts/"* "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/tls/server.crt"
  cp "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/tls/keystore/"* "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/tls/server.key"

  mkdir -p "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/msp/tlscacerts"
  cp "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/tls/tlscacerts/"* "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/msp/tlscacerts/tlsca.ganga.com-cert.pem"

  mkdir -p "${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts"
  cp "${FABRIC_CA_CLIENT_HOME}/orderers/${ORG_DOMAIN}/tls/tlscacerts/"* "${FABRIC_CA_CLIENT_HOME}/msp/tlscacerts/tlsca.ganga.com-cert.pem"
	
}
#+++++++++++++++++++++++++++++++++++++++++ Execute +++++++++++++++++++++++++++++++++++++++++++++++++++++

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
	generateTls
	rc=$?
fi


if [[ $rc -eq 0 ]];then
	generateMSP
	rc=$?
fi

if [[ $rc -eq 0 ]];then
	generateAdminMSP
	rc=$?
fi

if [[ $rc -eq 0 ]];then
	echo "generate artifacts"
else
	echo "Failed to generate certificates"
fi 

exit $rc

  