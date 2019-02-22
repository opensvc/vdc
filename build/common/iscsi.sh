#!/bin/bash

echo "Iscsi setup"

# old homemade iscsi tgt ISCSITGT="192.168.100.10"
# Freenas
#ISCSITGT="192.168.100.210"
echo
env|grep ^ISCSITGTIP
echo

[[ -z ${ISCSITGTIP} ]] && {
    echo "Error : ISCSITGTIP not found in environment"
    exit 1
}

cat - <<EOF >|/etc/multipath.conf
defaults {
	user_friendly_names no
	find_multipaths yes
}
EOF

sudo systemctl start multipathd.service

cat - <<EOF >|/etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.2009-11.com.opensvc.srv:$HOSTNAME.storage.initiator
EOF

echo ; echo

sed -i 's/^node.startup.*$/node.startup = automatic/' /etc/iscsi/iscsid.conf

sudo iscsiadm -m discovery -t st -p $ISCSITGTIP && {

    sudo iscsiadm  -m node | awk '{print $2}' | xargs -n 1 sudo iscsiadm -m node --login --targetname

}

# opensvc daemon reconfig to discover targets
[[ -f /opt/opensvc/etc/node.conf ]] && touch /opt/opensvc/etc/node.conf
[[ -f /etc/opensvc/node.conf ]] && touch /etc/opensvc/node.conf

exit 0
