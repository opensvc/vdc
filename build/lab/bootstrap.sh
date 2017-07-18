#!/bin/bash

# yum
sudo yum-config-manager --disable CentOS\*
sudo yum-config-manager --add-repo file:///data/repos/centos/7/base
sudo yum-config-manager --add-repo file:///data/repos/centos/7/extras
sudo yum-config-manager --add-repo file:///data/repos/centos/7/updates
sudo yum-config-manager --setopt="gpgcheck=0" --save

sudo yum install -y net-tools docker bridge-utils git runc wget bind-utils

# bugfixes
cd /usr/libexec/docker/
sudo ln -s docker-runc-current docker-runc
echo "PATH=\$PATH:/usr/libexec/docker" >>/etc/sysconfig/opensvc
sed -i -e "s/: false/: true/" /etc/oci-register-machine.conf

# bridges
node=$(hostname -s)
i=$(grep $node /data/vdc.nodes | awk '{print $2}')

sudo nmcli c add type bridge ifname br-prd con-name bridge-br-prd
sudo nmcli c mod bridge-br-prd bridge.stp no
sudo nmcli c mod bridge-br-prd ipv4.method manual ipv4.addresses 192.168.100.$i/24
sudo nmcli c mod bridge-br-prd +ipv4.routes "192.168.99.0/24 192.168.100.1"
sudo nmcli c mod "System eth1" connection.master br-prd connection.slave-type bridge
sudo nmcli c mod "System eth2" ipv4.method manual ipv4.addresses 192.168.101.$i/24
sudo nmcli c mod "System eth3" ipv4.method manual ipv4.addresses 192.168.102.$i/24

sudo nmcli c reload
sudo systemctl restart network

# ssh
sudo sed -i -e "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config                    
sudo systemctl restart sshd

# user
sudo useradd opensvc
sudo usermod -G vagrant opensvc
echo opensvc:opensvc | sudo chpasswd

# opensvc
sudo rpm -ivh /data/opensvc/rpms/current-1.8
sudo nodemgr set --param node.env --value PRD
sudo nodemgr set --param node.dbopensvc --value https://192.168.100.9

# install a collector
#sudo svcmgr -s collector create --template /data/opensvc/templates/collector.template --provision

