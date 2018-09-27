#!/bin/bash

cat - <<EOF >>/etc/profile.d/opensvc.alias.sh

alias upg_rpm="/data/opensvc/rpms/lab.upgrade.rpm.bash"
EOF

cat - <<EOF >>/root/.bash_aliases
alias vdcnfs="mount -t nfs 192.168.121.1:/data/vdc/share /data"
EOF

cat - <<EOF >>/root/.bash_aliases
alias array='nodemgr array --array freenas'

function niq {
        echo iqn.2009-11.com.opensvc.srv:\$1.storage.initiator
}
function tiq {
        echo iqn.2009-11.com.opensvc.srv:\$1.storage.target.\$2
}
EOF

cat - <<EOF >>/root/.bashrc
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF

