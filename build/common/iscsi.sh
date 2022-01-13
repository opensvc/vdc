#!/bin/bash

echo
echo "#######################"
echo "######## ISCSI ########"
echo "#######################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

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
        find_multipaths yes
        user_friendly_names no
}

blacklist {
        devnode "^drbd[0-9]"
        device {
                vendor "VBOX"
                product "HARDDISK"
        }
}

blacklist_exceptions {
        device {
                vendor "FreeNAS"
                product "iSCSI Disk"
        }
}
EOF

echo "Restarting multipathd systemd unit"
sudo multipath -F
sudo systemctl enable multipathd.service
sudo systemctl restart multipathd.service

echo "Creating /etc/iscsi/initiatorname.iscsi"
cat - <<EOF >|/etc/iscsi/initiatorname.iscsi
InitiatorName=iqn.2009-11.com.opensvc.srv:$HOSTNAME.storage.initiator
EOF

echo "Enabling automatic restart at boot"
sed -i 's/^node.startup.*$/node.startup = automatic/' /etc/iscsi/iscsid.conf

sudo systemctl -q is-active iscsi.service || {
    sudo systemctl enable --now iscsi.service
    sudo systemctl start iscsi.service
}

sudo iscsiadm -m discovery -t st -p $ISCSITGTIP && {

    sudo iscsiadm  -m node | awk '{print $2}' | xargs -n 1 sudo iscsiadm -m node --login --targetname

}

# opensvc daemon reconfig to discover targets
[[ -f /opt/opensvc/etc/node.conf ]] && touch /opt/opensvc/etc/node.conf
[[ -f /etc/opensvc/node.conf ]] && touch /etc/opensvc/node.conf

exit 0
