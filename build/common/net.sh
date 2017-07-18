#!/bin/bash

node=$(hostname -s)
i=$(grep $node /data/vdc.nodes | awk '{print $2}')

sudo nmcli c add type bridge ifname br-prd con-name bridge-br-prd
sudo nmcli c mod bridge-br-prd bridge.stp no
sudo nmcli c mod bridge-br-prd ipv4.method manual ipv4.addresses 192.168.100.$i/24
sudo nmcli c mod bridge-br-prd ipv4.routes "192.168.99.0/24 192.168.100.1"
sudo nmcli c mod "System eth1" connection.master br-prd connection.slave-type bridge
sudo nmcli c mod "System eth2" ipv4.method manual ipv4.addresses 192.168.101.$i/24
sudo nmcli c mod "System eth3" ipv4.method manual ipv4.addresses 192.168.102.$i/24

sudo nmcli c reload
sudo systemctl restart network

