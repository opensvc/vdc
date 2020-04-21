#!/bin/bash

echo
echo "#########################"
echo "######## NETWORK ########"
echo "#########################"
echo

. /vagrant/vdc.env

ls -l /vagrant

set -a

SLEEP=10

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
ip=$(grep -w ^$node /vagrant/vdc.nodes | sort -u | awk '{print $3}')
cluid=$(grep -w ^$node /vagrant/vdc.nodes | sort -u | awk '{print $2}')

#i=$(getent -s dns hosts ${node}|awk '{print $1}'|awk -F'.' '{print $4}'|sort -u)
echo
echo "found ip index <$ip>"
echo "found cluster id <$cluid>"
echo

[[ ! -f /vagrant/$HOSTNAME.showvminfo ]] && {
	echo "Error: missing mandatory /vagrant/$HOSTNAME.showvminfo"
	exit 1
}

echo "Identifying mac addr from vagrant showvminfo"
MAC0=$(grep "^NIC.*Attachment: NAT," /vagrant/${node}.showvminfo | awk -F, '{print $1}' | awk '{print $4}')
MAC1=$(grep "^NIC.*Attachment: Bridged Interface.*br-${cluid}-0" /vagrant/${node}.showvminfo | awk -F, '{print $1}' | awk '{print $4}')
MAC2=$(grep "^NIC.*Attachment: Bridged Interface.*br-${cluid}-1" /vagrant/${node}.showvminfo | awk -F, '{print $1}' | awk '{print $4}')
MAC3=$(grep "^NIC.*Attachment: Bridged Interface.*br-${cluid}-2" /vagrant/${node}.showvminfo | awk -F, '{print $1}' | awk '{print $4}')

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

cat << EOF > /etc/profile.d/osvc.nic.sh
export OSVC_NIC0=${NIC0}
export OSVC_NIC1=${NIC1}
export OSVC_NIC2=${NIC2}
export OSVC_NIC3=${NIC3}
EOF


# from here we have identified 4 nics defined in NIC0/1/2/3

if [ -f "/etc/debian_version" ]
then
for i in 1 2 3
do
        varname=NIC$i
        # needed for nmcli debian, to list device associated to connections
        ip link set ${!varname} down
        ip link set ${!varname} up
done
fi

# override unmanaged-devices=* in /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf
cat << EOF > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
[keyfile]
unmanaged-devices=*,except:type:wifi,except:type:wwan,except:interface-name:$NIC0,except:interface-name:$NIC1,except:interface-name:$NIC2,except:interface-name:$NIC3,except:interface-name:br-prd
EOF

if [ -f "/etc/debian_version" ]
then
	UNIT=network-manager
else
	UNIT=network
fi

sudo systemctl restart $UNIT || /bin/true
sleep $SLEEP

echo
echo "# before nmcli renaming"
sudo nmcli c show
echo

for nic in $NIC0 $NIC1 $NIC2 $NIC3
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
sudo nmcli c mod $bridge ipv4.routes "192.168.99.0/24 ${VDC_SUBNET_A}.${cluid}.0.1"
sudo nmcli c mod $bridge +ipv4.routes "192.168.200.0/24 ${VDC_SUBNET_A}.${cluid}.0.1"

sudo nmcli c mod $NIC0 ipv4.method auto
sudo nmcli c mod $NIC1 connection.master br-prd connection.slave-type bridge
sudo nmcli c mod $NIC2 ipv4.method manual ipv4.addresses ${VDC_SUBNET_A}.${cluid}.1.${ip}/24
sudo nmcli c down $NIC2 ; sudo nmcli c up $NIC2
sudo nmcli c mod $NIC3 ipv4.method manual ipv4.addresses ${VDC_SUBNET_A}.${cluid}.2.${ip}/24
sudo nmcli c down $NIC3 ; sudo nmcli c up $NIC3

sudo nmcli c show

sudo nmcli c reload
sudo systemctl restart $UNIT
sleep $SLEEP

sudo nmcli c up bridge-br-prd
