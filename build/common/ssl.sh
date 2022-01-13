#!/bin/bash

echo
echo "#####################"
echo "######## SSL ########"
echo "#####################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh


[[ -f /etc/redhat-release ]] && {
    sudo cp /data/opensvc/ssl/rapidssl.pem /etc/pki/ca-trust/source/anchors
    sudo /usr/bin/update-ca-trust
}

test -f /etc/apt/sources.list && {
    sudo cp /data/opensvc/ssl/rapidssl.pem /usr/local/share/ca-certificates/rapidssl.crt
    sudo /usr/sbin/update-ca-certificates
}

grep -qi 'CentOS Linux 7' /etc/os-release && {
	[[ ! -d /opt/openssl ]] && {
          tar xzf /data/nfspool/openssl.osvc.tar.gz -C /
          echo "pathmunge /opt/openssl/bin" > /etc/profile.d/openssl.sh
	  echo "/opt/openssl/lib" > /etc/ld.so.conf.d/openssl-1.1.1c.conf
	  ldconfig
        }
}

exit 0
