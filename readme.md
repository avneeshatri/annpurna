Annpurna Wallet Network
-----------------------
Annpurna is a decentralized platform for purchasing food items using Annpurna Crypto currency. Annpurna uses Account based model for wallets. Network is built on Hyperledger fabric. Online Restaurants , Online Food portals or Online Grocery Store can be added as a member of the network and user can use their wallets to purchases products on any member online portal.

Network Details
---------------
1 Orderer service
4 Organization consortium 
1 peer for each org (FCI, Zudexo, Ziggy ,Sabkabaazar)
CA Servers for each Org
Couch DB for each peer of organizations


Directory Structure
-------------------
Setup contains below directories 

doc
---
Documents with build steps for 
a)Peer and orderer services
b)Custom Endorsement Plugin
c)Custom Validation Plugin

docker
------
Docker composer files for bringing up fabric network.


network
-------
Network configurations
a)Channel Create Policy
b)configtx for config translator

organizations
-------------
Directory contains configuration for orderer and organization

scripts
-------
Scripts to setup network.

bin
---
Script to bring up 4 Org fabric network using docker.

bin-standalone
--------------
Scripts to bring up 4 Org stand alone network on local system.

cmd
---
Helper commands for setting up / testing a network 

conf
----
Config file for bring up network

external-builder
----------------
External Builder scripts for running chaincode / smart contracts

plugin
------
Custom Validation Plugin for Validation System Chaincode (VSCC)
Custom Endorsement Plugin for Endorsement System Chaincode (ESCC)
			