#!/bin/bash

echo
echo "#####################"
echo "######## SSL ########"
echo "#####################"
echo

[[ -f /etc/redhat-release ]] && {
    sudo cp /data/opensvc/ssl/rapidssl.pem /etc/pki/ca-trust/source/anchors
    sudo /usr/bin/update-ca-trust
}

test -f /etc/apt/sources.list && {
    sudo cp /data/opensvc/ssl/rapidssl.pem /usr/local/share/ca-certificates/rapidssl.crt
    sudo /usr/sbin/update-ca-certificates
}

exit 0
