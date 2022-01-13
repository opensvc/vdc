#!/bin/bash

set -a

echo
echo "#####################"
echo "######## LXC ########"
echo "#####################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

[[ -f /etc/redhat-release ]] && {
    sudo yum -y install debootstrap
}

grep -qEi "debian|ubuntu" /etc/os-release && {
	sudo apt install -y debootstrap
}

LXC_REPO=/nfspool/data/lxc
SRC_LXC_CACHE=${LXC_REPO}/cache
DST_LXC_CACHE=/var/cache/lxc

cd ${LXC_REPO} && {
echo "Populating LXC cache from ${LXC_REPO}"
#rsync -HAXpogDtrlx ${SRC_LXC_CACHE}/ ${DST_LXC_CACHE}

test -d ${DST_LXC_CACHE} || mkdir -p ${DST_LXC_CACHE}

for file in $(ls -1 *.tar)
do
    echo "=>    extracting archive ${file}"
    tar xf ${file} -C ${DST_LXC_CACHE}
done

echo
cd ${DST_LXC_CACHE} && ls -l
echo
}


test -f /usr/share/lxc/templates/lxc-ubuntuosvc || {
	test -d /usr/share/lxc/templates || mkdir -p /usr/share/lxc/templates
        echo "Copying lxc-ubuntuosvc template to /usr/share/lxc/templates/"
        cp ${LXC_REPO}/lxc-ubuntuosvc /usr/share/lxc/templates/
}

exit 0
