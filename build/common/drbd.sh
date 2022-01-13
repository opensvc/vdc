#!/bin/bash

echo
echo "######################"
echo "######## DRBD ########"
echo "######################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

set -a

[[ -f /etc/debian_version ]] && {
    DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:linbit/linbit-drbd9-stack
    DEBIAN_FRONTEND=noninteractive apt-get update
    DEBIAN_FRONTEND=noninteractive apt --no-install-recommends -y install linux-headers-$(uname -r) drbd-dkms drbd-utils
}

[[ -f /etc/redhat-release ]] && {
    DRBD_PACKAGES="drbd90-utils kmod-drbd90"
    yum -y install ${DRBD_PACKAGES}
}

grep -Eq "SLES|SUSE|Leap" /etc/os-release && {
    zypper --gpg-auto-import-keys -n --non-interactive install drbd-utils drbd-kmp-default
}

modprobe drbd || exit 1
modinfo drbd | grep ^version

DRBDTOP_BIN=/data/opensvc/bin/drbdtop

[[ ! -f /usr/local/bin/drbdtop ]] && {
    sudo cp $DRBDTOP_BIN /usr/bin/drbdtop
    sudo chmod a+x /usr/bin/drbdtop
}

exit 0
