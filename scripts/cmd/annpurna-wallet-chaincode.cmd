. /home/atri/workspace_hlf/annpurna/scripts/conf/net_deploy.cnf

#Zudexo
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

ORG_DOMAIN="zudexo.yamuna.com"
ORG_NAME="zudexo"
ORG_PORT="7051" 
ORG_MSPID="ZudexoMSP"


. /home/atri/workspace_hlf/annpurna/scripts/conf/hlf_client_org.cnf
. /home/atri/workspace_hlf/annpurna/scripts/conf/hlf_peer_org.cnf

#peer chaincode invoke -o localhost:8051 --ordererTLSHostnameOverride orderer.ganga.com --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CHAINCODE_NAME --peerAddresses $ZIGGY_CORE_PEER_ADDRESS --tlsRootCertFiles $ZIGGY_CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses $FCI_CORE_PEER_ADDRESS --tlsRootCertFiles $FCI_CORE_PEER_TLS_ROOTCERT_FILE --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE  -c '{"Args":["CreateWallet","{\"id\":\"button3\",\"status\":\"FOR_SALE\",\"properties\" :{\"color\":\"red\",\"size\":\"5mm\",\"shape\":\"round\"} , \"owner\":\"ZudexoMSP\"}"]}' --transient "{\"asset_properties\":\"$ASSET_PROPERTIES\"}" --waitForEvent


# Query Asset
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++
peer chaincode query -C $CHANNEL_NAME -n $CHAINCODE_NAME -c '{"Args":["ReadWallet","button3"]}'

