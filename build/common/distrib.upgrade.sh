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
	which dnf >> /dev/null 2>&1 && dnf upgrade --allowerasing --assumeyes --exclude="kernel*" && exit 0
        yum --assumeyes --exclude="kernel*" upgrade
}

exit 0
