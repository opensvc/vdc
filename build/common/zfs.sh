#!/bin/bash

echo
echo "#####################"
echo "######## ZFS ########"
echo "#####################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

# http://download.zfsonlinux.org/epel/zfs-release.el7_7.noarch.rpm

modprobe zfs >> /dev/null 2>&1 && exit 0

[[ -f /etc/redhat-release ]] && {

    VER=$(cat /etc/redhat-release | awk '{print $4}' | awk -F '.' '{printf $1 "_" $2 "\n"}')

    # dirty workaround for centos stream
    [ ${VER} = "8_" ] && VER="8_3"

    sudo yum -y install https://zfsonlinux.org/epel/zfs-release.el${VER}.noarch.rpm || exit 1
    sudo yum -y install yum-utils
    sudo yum-config-manager --disable zfs
    sudo yum-config-manager --enable zfs-kmod
    sudo yum -y install kernel-devel zfs
}

test -f /etc/apt/sources.list && grep -qi buster /etc/apt/sources.list && {
    echo deb http://deb.debian.org/debian buster contrib /etc/apt/sources.list
    gpg --keyserver pgpkeys.mit.edu --recv-key 04EE7237B7D453EC
    gpg -a --export 04EE7237B7D453EC | sudo apt-key add -sudo apt update
    sudo apt install -y zfs-dkms zfsutils-linux
}

grep -Eq "SLES|SUSE|Leap" /etc/os-release && {
    VER=$(grep ^VERSION_ID /etc/os-release | awk -F= '{print $2}' | sed -e 's@"@@g')
    MAJOR=$(echo ${VER} | awk -F. '{print $1}')
    MINOR=$(echo ${VER} | awk -F. '{print $2}')
    grep -Eq "SLES" /etc/os-release && {
        sudo zypper --gpg-auto-import-keys -n --non-interactive addrepo https://download.opensuse.org/repositories/filesystems/SLE_${MAJOR}_SP${MINOR}/filesystems.repo
    }
    grep -Eq "SUSE|Leap" /etc/os-release && {
        sudo zypper --gpg-auto-import-keys -n --non-interactive addrepo https://download.opensuse.org/repositories/filesystems/${VER}/filesystems.repo
    }
    sudo zypper --gpg-auto-import-keys refresh
    sudo zypper --gpg-auto-import-keys -n --non-interactive install zfs zfs-kmp-default
}

grep -qi ubuntu /etc/os-release && {
	sudo apt install -y zfsutils-linux
}

#if [ ! -e /sbin/zfs ]
#then
#  ZFSCMD=$(type zfs | awk '{print $4}' | sed -e 's/(//g;s/)//g')
#  ret=$?
#  if [ $ret -eq 0 ];
#  then
#      ln -sf ${ZFSCMD} /sbin/zfs
#  else
#      echo "/sbin/zfs not found"
#      exit 1
#  fi
#fi


depmod -a
modprobe zfs
lsmod | grep -qw zfs || exit 1
exit 0
