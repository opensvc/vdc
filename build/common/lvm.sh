#!/bin/bash

cat - <<EOF >>/etc/lvm/lvm.conf
tags {
    hosttags = 1
    local {}
}
EOF

cat - <<EOF >>/etc/lvm/lvm_$HOSTNAME.conf
activation {
    volume_list = ["@local", "@$HOSTNAME"]
}
EOF

vgchange --addtag local VolGroup00

