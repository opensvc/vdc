#!/bin/bash

echo
echo "#####################"
echo "######## YUM ########"
echo "#####################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

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
MAJOR_VERSION=$(grep ^VERSION_ID /etc/os-release | awk -F= '{print $2}' | sed -e 's/"//g')

# yum
sudo yum-config-manager -q --disable CentOS\* CentOS-8\* epel\* >> /dev/null 2>&1
[[ ! -d /root/yum.repos.d ]] && sudo mkdir /root/yum.repos.d
sudo mv /etc/yum.repos.d/CentOS* /etc/yum.repos.d/epel* /root/yum.repos.d/ 2>/dev/null

[[ ${MAJOR_VERSION} -eq 7 ]] && {
    sudo yum-config-manager -q --add-repo file:///mnt/repos/centos/${MAJOR_VERSION}/os/x86_64
    sudo yum-config-manager -q --add-repo file:///mnt/repos/centos/${MAJOR_VERSION}/extras/x86_64
    sudo yum-config-manager -q --add-repo file:///mnt/repos/centos/${MAJOR_VERSION}/updates/x86_64
    sudo yum-config-manager -q --add-repo file:///mnt/repos/epel/${MAJOR_VERSION}/x86_64
    sudo yum-config-manager -q --add-repo file:///mnt/repos/elrepo/el${MAJOR_VERSION}/x86_64
}

[[ ${MAJOR_VERSION} -eq 8 ]] && {
  ver='8'
  grep -qi stream /etc/os-release && ver='8-stream'

  sudo dnf config-manager -q --add-repo file:///mnt/repos/centos/${ver}/BaseOS/x86_64/os
  sudo dnf config-manager -q --add-repo file:///mnt/repos/centos/${ver}/extras/x86_64/os
  sudo dnf config-manager -q --add-repo file:///mnt/repos/centos/${ver}/AppStream/x86_64/os
  sudo dnf config-manager -q --add-repo file:///mnt/repos/centos/${ver}/PowerTools/x86_64/os

  sudo dnf config-manager -q --add-repo file:///mnt/repos/epel/${MAJOR_VERSION}/Everything/x86_64
  sudo dnf config-manager -q --add-repo file:///mnt/repos/elrepo/el${MAJOR_VERSION}/x86_64
}

sudo yum-config-manager -q --setopt="gpgcheck=0" --save
