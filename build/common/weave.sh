#!/bin/bash

set -a 

CNI_ROOT=/var/lib/opensvc/cni
CNI_BIN=$CNI_ROOT/bin
CNI_CONFIG=$CNI_ROOT/config

WEAVE_BIN=/data/cni/weave
WEAVE_CONFIG=/var/lib/opensvc/cni/config

[[ ! -f /usr/local/bin/weave ]] && {
    sudo cp $WEAVE_BIN /usr/local/bin/weave
    sudo chmod a+x /usr/local/bin/weave
}

[[ ! -d $WEAVE_CONFIG ]] && sudo mkdir -p $WEAVE_CONFIG
cat > $WEAVE_CONFIG/weave.conf <<EOF
{
    "cniVersion": "0.2.0",
    "name": "weave",
    "type": "weave-net"
}
EOF
