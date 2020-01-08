#!/bin/bash

echo
echo "#####################"
echo "######## CNI ########"
echo "#####################"
echo


[[ ! -d /usr/libexec/cni/bin ]] && {
    [[ -x /data/cni/cni.sh ]] && {
        echo "Installing CNI"
	/data/cni/cni.sh
    }
}

exit 0
