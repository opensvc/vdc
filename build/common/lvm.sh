#!/bin/bash

set -a

ROOTVG=$(lvs --noheadings -o name,vg_name | grep -w root | awk '{print $2}')


grep -q 'use_lvmetad = 1' /etc/lvm/lvm.conf || {
echo "Disable lvmetad"
cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.preosvc
cat /etc/lvm/lvm.conf.preosvc | sed -e 's/use_lvmetad = 1/use_lvmetad = 0/g' > /etc/lvm/lvm.conf
rm -f /etc/lvm/lvm.conf.preosvc
}

grep -q 'hosttags = 1' /etc/lvm/lvm.conf || {
echo "Enable lvm hosttags parameter"
cat - <<EOF >>/etc/lvm/lvm.conf
tags {
    hosttags = 1
    local {}
}
EOF
}

grep -q volume_list /etc/lvm/lvm_$HOSTNAME.conf >> /dev/null 2>&1 || {
echo "Configure lvm hosttags"
cat - <<EOF >>/etc/lvm/lvm_$HOSTNAME.conf
activation {
    volume_list = ["@local", "@$HOSTNAME"]
}
EOF
}

if [ ! -z ${ROOTVG} ]
then
	echo "Add tag local to rootvg"
	vgchange --addtag local ${ROOTVG}
fi

exit 0
