#!/bin/bash

echo
echo "#########################"
echo "######## SELINUX ########"
echo "#########################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

[[ -f /etc/sysconfig/selinux ]] && {
	sudo setenforce 0
	sudo sed -i -e "s/^SELINUX=enforcing/SELINUX=disabled/" /etc/sysconfig/selinux
}

exit 0
