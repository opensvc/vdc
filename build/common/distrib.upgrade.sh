#!/bin/bash

echo
echo "################################"
echo "######## DISTRIB UPDATE ########"
echo "################################"
echo


[[ -f /etc/debian_version ]] && {
	DEBIAN_FRONTEND=noninteractive apt update
        DEBIAN_FRONTEND=noninteractive apt -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confmiss" dist-upgrade
}

[[ -f /etc/redhat-release ]] && {
        yum -y upgrade
}

exit 0
