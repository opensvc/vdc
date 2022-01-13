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

function getmac()
{
    local NIC=$1
    ip -brief link show | grep -w "^${NIC}" | awk '{print $3}'
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
export OSVC_NETCONFIG=etcsysconfig
export OSVC_NIC0=${NIC0}
export OSVC_NIC1=${NIC1}
export OSVC_NIC2=${NIC2}
export OSVC_NIC3=${NIC3}
export OSVC_VIP_NIC=${NIC1}
export OSVC_BR1=${OSVC_BR1}
EOF

echo
echo "/etc/sysconfig/network : Starting setup"
echo

cat << EOF > /etc/sysconfig/network/ifcfg-${OSVC_BR1}
BOOTPROTO='static'
BRIDGE='yes'
BRIDGE_FORWARDDELAY='0'
BRIDGE_PORTS='${NIC1}'
BRIDGE_STP='off'
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR="${VDC_SUBNET_A}.${cluid}.0.${ip}/24"
MTU=''
NAME=''
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
EOF

cat << EOF > /etc/sysconfig/network/ifcfg-${NIC1}
BOOTPROTO='none'
BRIDGE="${OSVC_BR1}"
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR=''
MTU=''
NAME='82540EM Gigabit Ethernet Controller'
NETMASK=''
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
EOF

cat << EOF > /etc/sysconfig/network/ifcfg-${NIC2}
BOOTPROTO='static'
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR="${VDC_SUBNET_A}.${cluid}.1.${ip}/24"
MTU=''
NAME='82540EM Gigabit Ethernet Controller'
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
EOF

cat << EOF > /etc/sysconfig/network/ifcfg-${NIC3}
BOOTPROTO='static'
BROADCAST=''
ETHTOOL_OPTIONS=''
IPADDR="${VDC_SUBNET_A}.${cluid}.2.${ip}/24"
MTU=''
NAME='82540EM Gigabit Ethernet Controller'
NETWORK=''
REMOTE_IPADDR=''
STARTMODE='auto'
EOF

service network restart

echo
echo "DNS : Starting setup"

sed -i 's/NETCONFIG_DNS_STATIC_SEARCHLIST.*/NETCONFIG_DNS_STATIC_SEARCHLIST="vdc.opensvc.com opensvc.com"/' /etc/sysconfig/network/config
sed -i 's/NETCONFIG_DNS_STATIC_SERVERS.*/NETCONFIG_DNS_STATIC_SERVERS="10.0.2.3"/' /etc/sysconfig/network/config
netconfig update -f

exit 0
