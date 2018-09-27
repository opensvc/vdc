#!/bin/bash

osvcbranch='1.9'

# user
sudo useradd opensvc
sudo usermod -G vagrant opensvc
echo opensvc:opensvc | sudo chpasswd

# opensvc
if [ -f "/etc/debian_version" ]
then
	dpkg -i /data/opensvc/deb/current-${osvcbranch}
else
	sudo rpm -ivh /data/opensvc/rpms/current-${osvcbranch}
fi
sudo nodemgr set --param node.env --value PRD
sudo nodemgr set --param node.dbopensvc --value https://192.168.100.9
sudo nodemgr set --param node.repopkg --value file:///data/opensvc
sudo nodemgr set --param node.branch --value ${osvcbranch}

#sudo svcmgr -s collector create --template /data/opensvc/templates/collector.template --provision
#sudo svcmgr -s registry create --template /data/opensvc/templates/registry.template --provision

# opensvc dns
#echo -e "nameserver 192.168.100.9\n" | sudo tee -a /etc/resolv.conf

# registry cert
if [ -d /etc/docker/certs.d ]
then
	sudo mkdir -p /etc/docker/certs.d/192.168.0.8 /etc/docker/certs.d/registry.infra /etc/docker/certs.d/registry.infra.vdc.opensvc.com
	sudo cp /data/opensvc/registry/registry/certs/server.crt /etc/docker/certs.d/192.168.0.8/ca.crt
	sudo cp /data/opensvc/registry/registry/certs/server.crt /etc/docker/certs.d/registry.infra/ca.crt
	sudo cp /data/opensvc/registry/registry/certs/server.crt /etc/docker/certs.d/registry.infra.vdc.opensvc.com/ca.crt
fi

cat > /etc/opensvc/auth.conf <<EOF
[freenas]
type = freenas
api = http://192.168.100.210/api/v1.0 
username = root
password = toto
EOF

