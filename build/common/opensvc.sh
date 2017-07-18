#!/bin/bash

# user
sudo useradd opensvc
sudo usermod -G vagrant opensvc
echo opensvc:opensvc | sudo chpasswd

# opensvc
sudo rpm -ivh /data/opensvc/rpms/current-1.8
sudo nodemgr set --param node.env --value PRD
sudo nodemgr set --param node.dbopensvc --value https://192.168.100.9
#sudo svcmgr -s collector create --template /data/opensvc/templates/collector.template --provision
#sudo svcmgr -s registry create --template /data/opensvc/templates/registry.template --provision

# opensvc dns
#echo -e "nameserver 192.168.100.9\n" | sudo tee -a /etc/resolv.conf

# registry cert
sudo mkdir -p /etc/docker/certs.d/192.168.0.8 /etc/docker/certs.d/registry.infra /etc/docker/certs.d/registry.infra.vdc.opensvc.com
sudo cp /data/opensvc/registry/registry/certs/server.crt /etc/docker/certs.d/192.168.0.8/ca.crt
sudo cp /data/opensvc/registry/registry/certs/server.crt /etc/docker/certs.d/registry.infra/ca.crt
sudo cp /data/opensvc/registry/registry/certs/server.crt /etc/docker/certs.d/registry.infra.vdc.opensvc.com/ca.crt
