#!/bin/bash

# temporary static nfs mount during build (can not rely on vagrant facility with virtualbox provider)
[[ ! -d /mnt ]] && mkdir /mnt
mount -o soft,ro,actimeo=2 ${VDCBOXIP}:${VDCBOXEXPORT} /mnt

# yum
sudo yum-config-manager --disable CentOS\*
sudo yum-config-manager --add-repo file:///mnt/repos/centos/7/base
sudo yum-config-manager --add-repo file:///mnt/repos/centos/7/extras
sudo yum-config-manager --add-repo file:///mnt/repos/centos/7/updates
sudo yum-config-manager --add-repo file:///mnt/repos/epel/7
sudo yum-config-manager --add-repo file:///mnt/repos/elrepo/7
sudo yum-config-manager --setopt="gpgcheck=0" --save

sudo yum install -y \
	net-tools \
	docker \
	bridge-utils \
	git \
	jq \
	links \
	runc \
	wget \
        bind-utils \
        mdadm \
        mlocate \
        sg3_utils \
        psmisc \
        iotop htop \
        python-requests python-crypto \
	python34 python34-requests python34-crypto

# bugfixes
cd /usr/libexec/docker/
sudo ln -s docker-runc-current docker-runc
echo "export PATH=\$PATH:/usr/libexec/docker" >>/etc/sysconfig/opensvc
sed -i -e "s/: false/: true/" /etc/oci-register-machine.conf

