#!/bin/bash

echo
echo "################################"
echo "######## DISTRIB UPDATE ########"
echo "################################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

#[[ ! -f /.vbox.guest.additions.is.installed && -e /data/vbox/VBoxGuestAdditions.iso ]] && {
#    mount -o loop /data/vbox/VBoxGuestAdditions.iso /mnt
#    sh /mnt/VBoxLinuxAdditions.run --nox11
#    touch /.vbox.guest.additions.is.installed
#}

#[[ ! -f /.vbox.guest.additions.is.installed && -e /vagrant/VBoxGuestAdditions.iso ]] && {
#    mount -o loop /vagrant/VBoxGuestAdditions.iso /mnt
#    sh /mnt/VBoxLinuxAdditions.run --nox11
#    touch /.vbox.guest.additions.is.installed
#}

[[ -f /etc/debian_version ]] && {
    # prevent kernel from being updated
    grep -qi ubuntu /etc/os-release && apt-mark hold linux-image-generic

	DEBIAN_FRONTEND=noninteractive apt update
        DEBIAN_FRONTEND=noninteractive apt -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confmiss" dist-upgrade
        DEBIAN_FRONTEND=noninteractive apt -y autoremove
}

[[ -f /etc/redhat-release ]] && {
	## which dnf >> /dev/null 2>&1 && dnf upgrade --allowerasing --assumeyes --exclude="kernel*"
	which dnf >> /dev/null 2>&1 && dnf upgrade --allowerasing --assumeyes
        ## yum --assumeyes --exclude="kernel*" upgrade
        yum --assumeyes upgrade
    rm -f /etc/yum.repos.d/CentOS* /etc/yum.repos.d/epel*

}

grep -Eq "SLES|SUSE|Leap" /etc/os-release && {
    sed -i "s,http://download.opensuse.org,https://mirrorcache.opensuse.org,g" /etc/zypp/repos.d/*.repo
    zypper --non-interactive --gpg-auto-import-keys update
}

## vbox images come with vagrant vboxsf kernel module built providing /vagrant shared folder
## /vagrant is needed for opensvc CI
## distro upgrade break vboxsf kernel module
## vboxsf reinstall procedure need kernel-devel & kernel-headers, and may not be available in the correct version in centos repos

exit 0
