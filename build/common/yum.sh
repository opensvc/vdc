#!/bin/bash

. /vagrant/vdc.env

echo
echo "#####################"
echo "######## YUM ########"
echo "#####################"
echo

# temporary static nfs mount during build (can not rely on vagrant facility with virtualbox provider)
[[ ! -d /mnt ]] && mkdir /mnt
NFSSRV=$(sudo ip route show dev br-prd | grep "^${VDC_SUBNET_A}." | awk '{print $1}' | sed -e 's@0/24@1@')

echo "NFS exports from server located at $NFSSRV :"
sudo showmount -e $NFSSRV

grep -q "${VDC_ROOT}/share /mnt nfs" /proc/mounts && {
        echo "Unmounting /mnt"
        umount /mnt
}

echo "Mounting ${NFSSRV}:${VDC_ROOT}/share on /mnt"
sudo mount -o soft,ro,actimeo=2 ${NFSSRV}:${VDC_ROOT}/share /mnt

echo "Configuring local yum nfs repos"
# yum
sudo yum-config-manager -q --disable CentOS\* epel\*
sudo yum-config-manager -q --add-repo file:///mnt/repos/centos/7/base
sudo yum-config-manager -q --add-repo file:///mnt/repos/centos/7/extras
sudo yum-config-manager -q --add-repo file:///mnt/repos/centos/7/updates
sudo yum-config-manager -q --add-repo file:///mnt/repos/epel/7
sudo yum-config-manager -q --add-repo file:///mnt/repos/elrepo/7
sudo yum-config-manager -q --setopt="gpgcheck=0" --save
