#!/bin/bash

echo
echo "#####################"
echo "######## ZFS ########"
echo "#####################"
echo

# http://download.zfsonlinux.org/epel/zfs-release.el7_7.noarch.rpm

modprobe zfs >> /dev/null 2>&1 && exit 0

[[ -f /etc/redhat-release ]] && {
    VER=$(cat /etc/redhat-release | awk '{print $4}' | awk -F '.' '{printf $1 "_" $2 "\n"}')
    sudo yum -y install http://download.zfsonlinux.org/epel/zfs-release.el${VER}.noarch.rpm || exit 1
    sudo yum -y install yum-utils
    sudo yum-config-manager --disable zfs
    sudo yum-config-manager --enable zfs-kmod
    sudo yum -y install zfs
}

test -f /etc/apt/sources.list && grep -qi buster /etc/apt/sources.list && {
    echo deb http://deb.debian.org/debian buster contrib /etc/apt/sources.list
    gpg --keyserver pgpkeys.mit.edu --recv-key 04EE7237B7D453EC
    gpg -a --export 04EE7237B7D453EC | sudo apt-key add -sudo apt update
    sudo apt install -y zfs-dkms zfsutils-linux
}

grep -qi ubuntu /etc/os-release && {
	sudo apt install -y zfsutils-linux
}

modprobe zfs
lsmod | grep -qw zfs || exit 1
