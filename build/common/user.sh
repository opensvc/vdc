#!/bin/bash

env | grep -q VAGRANTPASSWDBASE64HASH || {
	echo
	echo "Error : VAGRANTPASSWDBASE64HASH env variable is expected to be set. Exiting"
	echo
	exit 1
}

# user
getent passwd opensvc || {
	sudo useradd opensvc
	echo opensvc:opensvc | sudo chpasswd
}

getent group vagrant | grep -q opensvc || {
	sudo usermod -G vagrant opensvc
}

getent passwd vagrant && {
	echo "Changing password for user vagrant"
        echo "vagrant:$(echo ${VAGRANTPASSWDBASE64HASH} | base64 -d)" | sudo chpasswd --encrypted
}

getent passwd root && {
	echo "Changing password for user root"
        echo "root:$(echo ${VAGRANTPASSWDBASE64HASH} | base64 -d)" | sudo chpasswd --encrypted
}
