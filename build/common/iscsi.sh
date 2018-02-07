#!/bin/bash

ISCSITGT="192.168.100.10"

sudo yum install -y iscsi-initiator-utils device-mapper-multipath


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


sudo iscsiadm -m discovery -t st -p $ISCSITGT

for target in 1 2
do
    sudo iscsiadm  -m node  --targetname "iqn.2009-11.com.opensvc.srv:$HOSTNAME.storage.target.0$target" --portal "$ISCSITGT:3260" --login
done


