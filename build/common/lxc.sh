#!/bin/bash

echo
echo "#####################"
echo "######## LXC ########"
echo "#####################"
echo


[[ -f /etc/redhat-release ]] && {
    sudo yum -y install debootstrap
}

grep -qEi "debian|ubuntu" /etc/os-release && {
	sudo apt install -y debootstrap
}

LXC_REPO=/nfspool/data/lxc
SRC_LXC_CACHE=${LXC_REPO}/cache
DST_LXC_CACHE=/var/cache/lxc

echo "Populating LXC cache from ${SRC_LXC_CACHE}"
rsync -a ${SRC_LXC_CACHE}/ ${DST_LXC_CACHE}

test -f /usr/share/lxc/templates/lxc-ubuntuosvc || {
	test -d /usr/share/lxc/templates || mkdir -p /usr/share/lxc/templates
        echo "Copying lxc-ubuntuosvc template to /usr/share/lxc/templates/"
        cp ${LXC_REPO}/lxc-ubuntuosvc /usr/share/lxc/templates/
}

exit 0
