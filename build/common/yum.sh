#!/bin/bash

# temporary static nfs mount during build (can not rely on vagrant facility with virtualbox provider)
[[ ! -d /mnt ]] && mkdir /mnt
mount -o soft,ro,actimeo=2 ${VDCBOXIP}:${VDCBOXEXPORT} /mnt

# yum
sudo yum-config-manager -q --disable CentOS\*
sudo yum-config-manager -q --add-repo file:///mnt/repos/centos/7/base
sudo yum-config-manager -q --add-repo file:///mnt/repos/centos/7/extras
sudo yum-config-manager -q --add-repo file:///mnt/repos/centos/7/updates
sudo yum-config-manager -q --add-repo file:///mnt/repos/epel/7
sudo yum-config-manager -q --add-repo file:///mnt/repos/elrepo/7
sudo yum-config-manager -q --setopt="gpgcheck=0" --save
