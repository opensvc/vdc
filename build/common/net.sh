#!/bin/bash

echo
echo "#########################"
echo "######## NETWORK ########"
echo "#########################"
echo

set -a

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

VDCNODES="${QASCRIPTS}/vdc.nodes"
SHOWVMINFO="${QASCRIPTS}/${HOSTNAME}.showvminfo"
for f in ${VDCNODES} ${SHOWVMINFO}
do
    [[ ! -f ${f} ]] && echo "Error: missing mandatory file ${f} . Exiting" && exit 1
done

SLEEP=10

OSVC_BR1="br-prd"

NIC0="none"
NIC1="none"
NIC2="none"
NIC3="none"

# build eth list
# eth0 : admin nic
# eth1 : prod (encap in bridge)
# eth2 : hb1
# eth3 : hb2

function mac2nic()
{
    local MAC=$1
    ip -brief link show | grep -Ev "^docker|^br-|^lxc|^lo" | sed -e 's/://g' | awk '{print $1 " " toupper($3)}' | grep -w ${MAC} | awk '{print $1}'
}

echo
echo "# link list"
ip -brief link show
echo
echo

node=$(hostname -s)
ip=$(grep -w ^$node ${VDCNODES} | sort -u | awk '{print $3}')
cluid=$(grep -w ^$node ${VDCNODES} | sort -u | awk '{print $2}')

#i=$(getent -s dns hosts ${node}|awk '{print $1}'|awk -F'.' '{print $4}'|sort -u)
echo
echo "found ip index <$ip>"
echo "found cluster id <$cluid>"
echo
cat << EOF > ${QASCRIPTS}/01.cluster.sh
export OSVC_CLUSTER_NUMBER=${cluid}
export OSVC_CLUSTER_NAME=cluster${cluid}
EOF


echo "Identifying mac addr from vagrant showvminfo"
MAC0=$(grep "^NIC.*Attachment: NAT," ${SHOWVMINFO} | awk -F, '{print $1}' | awk '{print $4}')
MAC1=$(grep "^NIC.*Attachment: Bridged Interface.*br-${cluid}-0" ${SHOWVMINFO} | awk -F, '{print $1}' | awk '{print $4}')
MAC2=$(grep "^NIC.*Attachment: Bridged Interface.*br-${cluid}-1" ${SHOWVMINFO} | awk -F, '{print $1}' | awk '{print $4}')
MAC3=$(grep "^NIC.*Attachment: Bridged Interface.*br-${cluid}-2" ${SHOWVMINFO} | awk -F, '{print $1}' | awk '{print $4}')

echo "Resolving ip link name from mac addr"
for i in 0 1 2 3
do
	macname=MAC$i
	nic=`mac2nic ${!macname}`
	eval NIC$i=$nic
done

echo "Nic mapping"
for i in 0 1 2 3
do
	nicname=NIC$i
	macname=MAC$i
	echo NIC$i=${!nicname}    MAC$i=${!macname}
done

cat << EOF > ${QASCRIPTS}/05.net.sh
export OSVC_NETCONFIG=networkmanager
export OSVC_NIC0=${NIC0}
export OSVC_NIC1=${NIC1}
export OSVC_NIC2=${NIC2}
export OSVC_NIC3=${NIC3}
export OSVC_VIP_NIC=${NIC1}
export OSVC_BR1=${OSVC_BR1}
EOF


# from here we have identified 4 nics defined in NIC0/1/2/3

if [ -f "/etc/debian_version" ]
then
for i in 1 2 3
do
        varname=NIC$i
        # needed for nmcli debian, to list device associated to connections
	echo "Initiate down/up for nic ${!varname}"
        ip link set ${!varname} down && sleep 1 && ip link set ${!varname} up
done
fi

# override unmanaged-devices=* in /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf
cat << EOF > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
[keyfile]
unmanaged-devices=*,except:interface-name:$NIC0,except:interface-name:$NIC1,except:interface-name:$NIC2,except:interface-name:$NIC3,except:interface-name:${OSVC_BR1}
EOF

#if [ -f "/etc/debian_version" ]
#then
#	UNIT=network-manager
#else
#	UNIT=network
#fi

UNIT=""
for unit in network-manager network NetworkManager
do
   systemctl -q enable $unit || /bin/true
   systemctl -q enable NetworkManager-wait-online.service || /bin/true
   systemctl -q is-enabled $unit && {
     UNIT=$unit 
     break
   }
done
echo "Found systemd unit >$UNIT<"

# dump nic state before restart
ip link show | grep ^[1-9]
echo

sudo systemctl restart $UNIT || /bin/true
sleep $SLEEP

# dump nic state after restart
ip link show | grep ^[1-9]
echo

echo
echo "# before nmcli renaming"
sudo nmcli c show
echo

echo
echo "# before nmcli renaming - active connections only"
sudo nmcli c show --active
echo

# remove any connection which is not associated with an interface
sudo nmcli -t --fields name,uuid,device c show | awk -F: '$3 ~ /^$/ {print $2}' | xargs -r -n 1 sudo nmcli c del uuid

echo
echo "# after nmcli connection cleanup"
sudo nmcli c show
echo

# u20.04 need to modify vagrant base nic while connection is down
# before : 
# NAME                UUID                                  TYPE      DEVICE
# Wired connection 1  234788c5-cade-3cbb-ae07-b7c0bf5d29e9  ethernet  eth0
       
NAMENIC0=$(sudo nmcli -t --fields name,uuid,device c show | grep $NIC0 | awk -F':' '{print $1}')
UUIDNIC0=$(sudo nmcli -t --fields name,uuid,device c show | grep $NIC0 | awk -F':' '{print $2}')
if [ "${NAMENIC0}" != "${NIC0}" ]; then
    echo "Reconfiguring connection name ${NAMENIC0}" 
    exec 2>/dev/null
    echo "sudo nmcli c down uuid ${UUIDNIC0} && sleep 2 && sudo nmcli c modify uuid ${UUIDNIC0} connection.id $NIC0 && sleep 5 && sudo nmcli c up uuid ${UUIDNIC0} && sleep 5"
    sudo nmcli c down uuid ${UUIDNIC0} && sleep 2 && sudo nmcli c modify uuid ${UUIDNIC0} connection.id $NIC0 && sleep 5 && sudo nmcli c up uuid ${UUIDNIC0} && sleep 5
    exec 2>&2
fi

# after :
# NAME           UUID                                  TYPE      DEVICE
# eth0           234788c5-cade-3cbb-ae07-b7c0bf5d29e9  ethernet  eth0


for nic in $NIC1 $NIC2 $NIC3
do
    uuid=$(sudo nmcli -t --fields name,uuid,device c show | grep $nic | awk -F':' '{print $2}')
    sudo nmcli c modify uuid $uuid connection.id $nic 2>/dev/null || sudo nmcli c add type ethernet ifname $nic con-name $nic autoconnect yes save yes
done

echo
echo "# after nmcli renaming"
sudo nmcli c show
echo
echo

bridge=bridge-br-prd
nmcli c show | grep -q $bridge || {
	sudo nmcli c add type bridge ifname br-prd con-name $bridge
}
sudo nmcli c mod $bridge bridge.stp no
sudo nmcli c mod $bridge ipv4.method manual ipv4.addresses ${VDC_SUBNET_A}.${cluid}.0.${ip}/24
sudo nmcli c mod $bridge ipv6.method manual ipv6.addresses fd00:0:${cluid}:0::${ip}/64
sudo nmcli c mod $bridge ipv4.routes "192.168.99.0/24 ${VDC_SUBNET_A}.${cluid}.0.1"
sudo nmcli c mod $bridge +ipv4.routes "192.168.200.0/24 ${VDC_SUBNET_A}.${cluid}.0.1"

sudo nmcli c mod $NIC0 ipv4.method auto
sudo nmcli c mod $NIC1 connection.master br-prd connection.slave-type bridge
sudo nmcli c mod $NIC2 ipv4.method manual ipv4.addresses ${VDC_SUBNET_A}.${cluid}.1.${ip}/24
sudo nmcli c mod $NIC2 ipv6.method manual ipv6.addresses fd00:0:${cluid}:1::${ip}/64
sudo nmcli c down $NIC2 ; sudo nmcli c up $NIC2
sudo nmcli c mod $NIC3 ipv4.method manual ipv4.addresses ${VDC_SUBNET_A}.${cluid}.2.${ip}/24
sudo nmcli c mod $NIC3 ipv6.method manual ipv6.addresses fd00:0:${cluid}:2::${ip}/64
sudo nmcli c down $NIC3 ; sudo nmcli c up $NIC3

sudo nmcli c show

sudo nmcli c reload
sudo systemctl restart $UNIT
sleep $SLEEP

sudo nmcli c down $NIC1
sudo nmcli c up $bridge
sudo nmcli c up $NIC1

echo
echo "# end of network script"
sudo nmcli c show
echo
echo
