Commands
________

Create Service
--------------
sudo cp fabric-orderer.service /etc/systemd/system/

sudo systemctl enable fabric-orderer.service

Manage Service
--------------
sudo systemctl daemon-reload

sudo systemctl start fabric-orderer.service

sudo systemctl stop fabric-orderer.service

sudo systemctl restart fabric-orderer.service

systemctl status fabric-orderer.service

View Logs
---------
journalctl -u fabric-orderer