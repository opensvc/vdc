#!/bin/bash

ETH0="eth0"
ETH1="eth1"
ETH2="eth2"
ETH3="eth3"

if [ -f "/etc/debian_version" ]
then
	grep -i ubuntu /etc/lsb-release || {
		ETH0="ens9"
		ETH1="ens10"
		ETH2="ens11"
		ETH3="ens12"
	}
	UNIT=network-manager
	sudo systemctl start $UNIT || /bin/true
else
	UNIT=network
fi
node=$(hostname -s)
i=$(grep $node /data/vdc.nodes | awk '{print $2}')

#sudo nmcli -t --fields UUID,DEVICE c | grep -v $ETH0 | cut -d: -f1 | xargs -n1 sudo nmcli c del uuid
sudo nmcli -t --fields UUID,DEVICE c | cut -d: -f1 | xargs -n1 sudo nmcli c del uuid

sudo nmcli c add type bridge ifname br-prd con-name bridge-br-prd
sudo nmcli c mod bridge-br-prd bridge.stp no
sudo nmcli c mod bridge-br-prd ipv4.method manual ipv4.addresses 192.168.100.$i/24
sudo nmcli c mod bridge-br-prd ipv4.routes "192.168.99.0/24 192.168.100.1"
sudo nmcli c add type ethernet con-name eth0 ifname $ETH0 -- ipv4.method auto
sudo nmcli c add type ethernet con-name eth1 ifname $ETH1 -- connection.master br-prd connection.slave-type bridge
sudo nmcli c add type ethernet con-name eth2 ifname $ETH2 -- ipv4.method manual ipv4.addresses 192.168.101.$i/24
sudo nmcli c add type ethernet con-name eth3 ifname $ETH3 -- ipv4.method manual ipv4.addresses 192.168.102.$i/24

sudo nmcli c reload
sudo systemctl restart $UNIT
sudo nmcli c up bridge-br-prd

