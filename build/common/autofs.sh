#/bin/bash

echo "########################"
echo "######## AUTOFS ########"
echo "########################"

set -a
[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

# systemctl status nfs-mountd.service

grep -q ' /data nfs' /proc/mounts && {
	echo "Unmounting /data & deleting /data"
	umount /data && rmdir /data
}

grep -q "${VDC_ROOT}/share /mnt nfs" /proc/mounts && {
	echo "Unmounting /mnt"
	umount /mnt
}

[[ ! -d /etc/auto.master.d ]] && mkdir -p /etc/auto.master.d

cat - <<EOF >|/etc/auto.master.d/osvcdata.autofs
${VMAUTOFSROOT}    /etc/auto.osvcdata    --ghost,--timeout=30
/nfspool   /etc/auto.nfspool     --ghost,--timeout=30
EOF

NFSSRV="${VDC_SUBNET_A}.${OSVC_CLUSTER_NUMBER}.0.1"

[[ -z ${NFSSRV} ]] && echo "Error: NFSSRV is not defined" && exit 1

cat - <<EOF >|/etc/auto.osvcdata
${VMAUTOFSKEY} -fstype=nfs,ro,soft,actimeo=2,rsize=8192,wsize=8192   ${NFSSRV}:${VDC_ROOT}/share
EOF


cat - <<EOF >|/etc/auto.nfspool
${VMAUTOFSKEY} -fstype=nfs,rw,soft,actimeo=2,rsize=8192,wsize=8192   ${NFSSRV}:${VDC_ROOT}/share/nfspool
EOF

grep -q "^#+dir:/etc/auto.master.d" /etc/auto.master && {
sudo sed -i -e "s/^#+dir:\/etc\/auto.master.d/+dir:\/etc\/auto.master.d/" /etc/auto.master
}

echo "Enabling autofs.service systemd unit"
sudo systemctl enable autofs.service

echo "Restarting autofs.service systemd unit"
sudo systemctl restart autofs.service

[[ ! -L /data ]] && {
	echo "Creating /data symlink to ${VMAUTOFSROOT}/${VMAUTOFSKEY}"
	ln -sf ${VMAUTOFSROOT}/${VMAUTOFSKEY} /data
}

[[ -f /etc/yum.conf ]] && {
    # switch to autofs repos
    yum clean all
    rm -rf /var/cache/yum/* /etc/yum.repos.d/*
    MAJOR_VERSION=$(grep ^VERSION_ID /etc/os-release | awk -F= '{print $2}' | sed -e 's/"//g')

    [[ ${MAJOR_VERSION} -eq 7 ]] && {
        sudo yum-config-manager -q --add-repo file:///data/repos/centos/${MAJOR_VERSION}/os/x86_64
        sudo yum-config-manager -q --add-repo file:///data/repos/centos/${MAJOR_VERSION}/extras/x86_64
        sudo yum-config-manager -q --add-repo file:///data/repos/centos/${MAJOR_VERSION}/updates/x86_64
        sudo yum-config-manager -q --add-repo file:///data/repos/epel/${MAJOR_VERSION}/x86_64
        sudo yum-config-manager -q --add-repo file:///data/repos/elrepo/el${MAJOR_VERSION}/x86_64
    }

    [[ ${MAJOR_VERSION} -eq 8 ]] && {
      ver='8'
      grep -qi stream /etc/os-release && ver='8-stream'

      sudo dnf config-manager -q --add-repo file:///data/repos/centos/${ver}/BaseOS/x86_64/os
      sudo dnf config-manager -q --add-repo file:///data/repos/centos/${ver}/extras/x86_64/os
      sudo dnf config-manager -q --add-repo file:///data/repos/centos/${ver}/AppStream/x86_64/os
      sudo dnf config-manager -q --add-repo file:///data/repos/centos/${ver}/PowerTools/x86_64/os

      sudo dnf config-manager -q --add-repo file:///data/repos/epel/${MAJOR_VERSION}/Everything/x86_64
      sudo dnf config-manager -q --add-repo file:///data/repos/elrepo/el${MAJOR_VERSION}/x86_64
}


    sudo yum repolist
}

exit 0
