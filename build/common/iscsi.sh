#!/bin/bash

echo
echo "#######################"
echo "######## ISCSI ########"
echo "#######################"
echo

[[ -z ${ISCSITGTIP} ]] && {
    echo "Error : ISCSITGTIP not found in environment"
    exit 1
}

ping -q -w 1 ${ISCSITGTIP} >> /dev/null 2>&1 || {
	echo "Error : ISCSITGTIP ${ISCSITGTIP} is not available"
        exit 1
}

echo "Creating /etc/multipath.conf"
cat - <<EOF >|/etc/multipath.conf
defaults {
	user_friendly_names no
	find_multipaths yes
}
EOF

echo "Restarting multipathd systemd unit"
sudo systemctl start multipathd.service

echo "Creating /etc/iscsi/initiatorname.iscsi"
cat - <<EOF >|/etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.2009-11.com.opensvc.srv:$HOSTNAME.storage.initiator
EOF

echo "Enabling automatic restart at boot"
sed -i 's/^node.startup.*$/node.startup = automatic/' /etc/iscsi/iscsid.conf

sudo iscsiadm -m discovery -t st -p $ISCSITGTIP && {

    sudo iscsiadm  -m node | awk '{print $2}' | xargs -n 1 sudo iscsiadm -m node --login --targetname

}

# opensvc daemon reconfig to discover targets
[[ -f /opt/opensvc/etc/node.conf ]] && touch /opt/opensvc/etc/node.conf
[[ -f /etc/opensvc/node.conf ]] && touch /etc/opensvc/node.conf

exit 0
