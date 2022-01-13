#!/bin/bash

echo
echo "######################"
echo "######## USER ########"
echo "######################"
echo
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

env | grep -q VAGRANTPASSWDBASE64HASH || {
	echo
	echo "Error : VAGRANTPASSWDBASE64HASH env variable is expected to be set. Exiting"
	echo
	exit 1
}

# user
getent passwd opensvc || {
	echo "Creating user opensvc"
	sudo useradd opensvc
	if which chpasswd > /dev/null 2>&1; then
        echo opensvc:opensvc | sudo chpasswd
    else
        sudo passwd -p '$5$rounds=10000$.cAEPqRC$W4GGmG3xOEqFcsu2ZcPM5pcQ26xdrJUep2ytK1A9qE7' opensvc
    fi
}

getent group vagrant || {
	echo "Adding vagrant group"
    groupadd vagrant
}

getent group vagrant | grep -q opensvc || {
	echo "Adding opensvc user to vagrant group"
	sudo usermod -G vagrant opensvc
}

getent passwd vagrant && {
	echo "Changing password for user vagrant"
    if which chpasswd > /dev/null 2>&1 ;then
        echo "vagrant:$(echo ${VAGRANTPASSWDBASE64HASH} | base64 -d)" | sudo chpasswd --encrypted
    else
        sudo passwd -p "${VAGRANTPASSWDBASE64HASH}" vagrant
    fi
}

getent passwd root && {
	echo "Changing password for user root"
	if which chpasswd > /dev/null 2>&1 ; then
        echo "root:$(echo ${VAGRANTPASSWDBASE64HASH} | base64 -d)" | sudo chpasswd --encrypted
    else
        sudo passwd -p "${VAGRANTPASSWDBASE64HASH}" root
    fi
}

