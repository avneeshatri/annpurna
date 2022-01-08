cd /home/atri/workspace_hlf/annpurna/scripts/fabric-daemons

export FABRIC_CA_HOME=/home/atri/workspace_hlf/annpurna/organizations/fci/fabric-ca-standalone
export FABRIC_CA_SERVER_CA_NAME=ca-fci
export FABRIC_CA_SERVER_TLS_ENABLED=true
export FABRIC_CA_SERVER_PORT=7154

sh -c './fabric-ca-server start -b admin:adminpw -d'