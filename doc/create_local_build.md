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
make peer
make orderer