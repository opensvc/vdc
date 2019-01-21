#/bin/bash

# systemctl status nfs-mountd.service

grep -q ' /data nfs' /proc/mounts && {
	umount /data && rmdir /data
}

grep -q '/data/vdc/share /mnt nfs' /proc/mounts && {
	umount /mnt
}

cat - <<EOF >|/etc/auto.master.d/osvcdata.autofs
${VMAUTOFSROOT}    /etc/auto.osvcdata    --ghost,--timeout=30
EOF

cat - <<EOF >|/etc/auto.osvcdata
${VMAUTOFSKEY} -fstype=nfs,ro,soft,actimeo=2,rsize=8192,wsize=8192   ${VDCBOXIP}:${VDCBOXEXPORT}
EOF

systemctl enable autofs.service
systemctl restart autofs.service

[[ ! -L /data ]] && {
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
