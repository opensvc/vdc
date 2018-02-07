#!/bin/bash

# yum
sudo yum-config-manager --disable CentOS\*
sudo yum-config-manager --add-repo file:///data/repos/centos/7/base
sudo yum-config-manager --add-repo file:///data/repos/centos/7/extras
sudo yum-config-manager --add-repo file:///data/repos/centos/7/updates
sudo yum-config-manager --add-repo file:///data/repos/epel/7
sudo yum-config-manager --add-repo file:///data/repos/elrepo/7
sudo yum-config-manager --setopt="gpgcheck=0" --save

sudo yum install -y \
	net-tools \
	docker \
	bridge-utils \
	git \
	runc \
	wget \
        bind-utils \
        python-requests \
        mdadm \
        mlocate \
        sg3_utils \
        psmisc \
        iotop \
	python-crypto \
        htop

# bugfixes
cd /usr/libexec/docker/
sudo ln -s docker-runc-current docker-runc
echo "export PATH=\$PATH:/usr/libexec/docker" >>/etc/sysconfig/opensvc
sed -i -e "s/: false/: true/" /etc/oci-register-machine.conf

