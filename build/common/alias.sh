#!/bin/bash

echo
echo "#######################"
echo "######## ALIAS ########"
echo "#######################"
echo 

echo "Creating /etc/profile.d/opensvc.alias.sh"
cat - <<EOF >>/etc/profile.d/opensvc.alias.sh

alias upg_rpm="/data/opensvc/rpms/lab.upgrade.rpm.bash"
EOF


echo "Updating /root/.bash_aliases for freenas (array, niq, tiq)"
cat - <<EOF >>/root/.bash_aliases
alias array='nodemgr array --array freenas'

function niq {
        echo iqn.2009-11.com.opensvc.srv:\$1.storage.initiator
}
function tiq {
        echo iqn.2009-11.com.opensvc.srv:\$1.storage.target.\$2
}
EOF

echo "Updating /root/.bashrc to ensure alias sourcing"
cat - <<EOF >>/root/.bashrc
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
EOF

