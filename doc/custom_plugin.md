#Go into local go src path for fabric repository checkout
cd /home/atri/go/src/github.com/hyperledger/fabric

#Create directory

mkdir -p custom/plugin

#create plugin file in above directory
Take plugin .go file from annpurna git checkout . 


#build peer and orderer artifacts
make peer
make orderer #optional

#build custom plugin
GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build -o release/linux-amd64/bin/customPlugin.so -tags "" -ldflags "-X github.com/hyperledger/fabric/common/metadata.Version=2.3.3 -X github.com/hyperledger/fabric/common/metadata.CommitSHA=8fd2ad8c6 -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger" -buildmode=plugin  github.com/hyperledger/fabric/custom/plugin

#Test plugin test module
mkdir -p custom/test

#Checkout test run .go file from git annpurna and place it in above directory

#Execute below command , no err must be returned
go run custom/test/plugin_check.go


#Use generated plugin .so file in core.yaml and peer cli for starting node server