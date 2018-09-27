#!/bin/bash

set -a 

DRBD_PACKAGES="drbd84-utils kmod-drbd84"
DRBDTOP_BIN=/data/opensvc/bin/drbdtop

yum -y install ${DRBD_PACKAGES}

[[ ! -f /usr/local/bin/drbdtop ]] && {
    sudo cp $DRBDTOP_BIN /usr/local/bin/drbdtop
    sudo chmod a+x /usr/local/bin/drbdtop
}
