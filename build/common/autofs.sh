#/bin/bash

. /vagrant/vdc.env

echo "########################"
echo "######## AUTOFS ########"
echo "########################"

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

NFSSRV=$(sudo ip route show dev br-prd | awk '{print $1}' | sed -e 's@0/24@1@')

cat - <<EOF >|/etc/auto.osvcdata
${VMAUTOFSKEY} -fstype=nfs,ro,soft,actimeo=2,rsize=8192,wsize=8192   ${NFSSRV}:${VDC_ROOT}/share
EOF


cat - <<EOF >|/etc/auto.nfspool
${VMAUTOFSKEY} -fstype=nfs,rw,soft,actimeo=2,rsize=8192,wsize=8192   ${NFSSRV}:${VDC_ROOT}/share/nfspool
EOF

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
    sudo yum-config-manager -q --add-repo file:///data/repos/centos/7/base
    sudo yum-config-manager -q --add-repo file:///data/repos/centos/7/extras
    sudo yum-config-manager -q --add-repo file:///data/repos/centos/7/updates
    sudo yum-config-manager -q --add-repo file:///data/repos/epel/7
    sudo yum-config-manager -q --add-repo file:///data/repos/elrepo/7
    sudo yum repolist
}

exit 0
