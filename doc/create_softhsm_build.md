Create directory in go src path
---------------------------------
mkdir -p /home/atri/go/src/github.com/hyperledger
cd /home/atri/go/src/github.com/hyperledger


Checkout fabric repository
--------------------------
git clone git@github.com:hyperledger/fabric.git
cd fabric

Perform cleanup
-----------------------
make cleanup

Prepare peer orderer cli library
-------------------------------
GO_TAGS=pkcs11 make peer
GO_TAGS=pkcs11 make orderer


Checkout fabric-ca repository 
-------------------------------
cd /home/atri/go/src/github.com/hyperledger
git clone git@github.com:hyperledger/fabric-ca.git
cd fabric-ca

Prepare peer orderer cli library
-------------------------------
make clean
GO_TAGS=pkcs11 make fabric-ca-server
GO_TAGS=pkcs11 make fabric-ca-client
