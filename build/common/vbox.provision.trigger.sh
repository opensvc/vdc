#!/bin/bash

for vm in $(vagrant status | grep '(virtualbox)' | grep -v 'not created' | awk '{print $1}')
do
	echo
	echo --- $vm ---
	vboxmanage showvminfo ${vm} --details > ${vm}.showvminfo
	cat ${vm}.showvminfo | grep ^NIC | grep MAC
done
