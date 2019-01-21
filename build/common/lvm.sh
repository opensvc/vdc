#!/bin/bash

grep -q 'use_lvmetad = 1' /etc/lvm/lvm.conf || {
cp /etc/lvm/lvm.conf /etc/lvm/lvm.conf.preosvc
cat /etc/lvm/lvm.conf.preosvc | sed -e 's/use_lvmetad = 1/use_lvmetad = 0/g' > /etc/lvm/lvm.conf
rm -f /etc/lvm/lvm.conf.preosvc
}

grep -q 'hosttags = 1' /etc/lvm/lvm.conf || {
cat - <<EOF >>/etc/lvm/lvm.conf
tags {
    hosttags = 1
    local {}
}
EOF
}

grep -q volume_list /etc/lvm/lvm_$HOSTNAME.conf || {
cat - <<EOF >>/etc/lvm/lvm_$HOSTNAME.conf
activation {
    volume_list = ["@local", "@$HOSTNAME"]
}
EOF
}

if [ ! -f "/etc/debian_version" ]
then
	vgchange --addtag local VolGroup00
fi

exit 0
