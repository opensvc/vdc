#!/bin/bash

ls -l /vagrant

set -a

SLEEP=10

ETH0="none"
ETH1="none"
ETH2="none"
ETH3="none"

# build eth list
# eth0 : admin nic
# eth1 : prod (encap in bridge)
# eth2 : hb1
# eth3 : hb2

echo
echo "# link list"
ip -brief link show
echo
echo

typeset -i index=0
for nic in $(ip -brief link show | grep -Ev "^lo|^br-|^docker" | awk '{print $1}')
do
	eval ETH$index=$nic
	let index=$index+1
done

for i in 0 1 2 3
do
	varname=ETH$i
	echo ETH$i=${!varname}
done

if [ -f "/etc/debian_version" ]
then
for i in 1 2 3
do
	varname=ETH$i
	# needed for nmcli debian, to list device associated to connections
	ip link set ${!varname} down
	ip link set ${!varname} up
done
fi

# from here we have identified 4 nics defined in ETH0/1/2/3

# override unmanaged-devices=* in /usr/lib/NetworkManager/conf.d/10-globally-managed-devices.conf
cat << EOF > /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
[keyfile]
unmanaged-devices=*,except:type:wifi,except:type:wwan,except:interface-name:$ETH0,except:interface-name:$ETH1,except:interface-name:$ETH2,except:interface-name:$ETH3,except:interface-name:br-prd
EOF

if [ -f "/etc/debian_version" ]
then
	UNIT=network-manager
else
	UNIT=network
fi

sudo systemctl restart $UNIT || /bin/true
sleep $SLEEP

node=$(hostname -s)
i=$(grep $node /vagrant/vdc.nodes | awk '{print $2}')
#i=$(getent -s dns hosts ${node}|awk '{print $1}'|awk -F'.' '{print $4}'|sort -u)
echo
echo "found ip index <$i>"
echo
echo
echo "# before nmcli renaming"
sudo nmcli c show
echo

for nic in $ETH0 $ETH1 $ETH2 $ETH3
do
    uuid=$(sudo nmcli -t --fields name,uuid,device c show | grep $nic | awk -F':' '{print $2}')
    sudo nmcli c modify uuid $uuid connection.id $nic || sudo nmcli c add type ethernet ifname $nic con-name $nic autoconnect yes save yes
done

echo
echo "# after nmcli renaming"
sudo nmcli c show
echo
echo

bridge=bridge-br-prd
nmcli c show | grep -q $bridge || {
	sudo nmcli c add type bridge ifname br-prd con-name $bridge
	sudo nmcli c mod $bridge bridge.stp no
	sudo nmcli c mod $bridge ipv4.method manual ipv4.addresses 192.168.100.$i/24
	sudo nmcli c mod $bridge ipv4.routes "192.168.99.0/24 192.168.100.1"
}

sudo nmcli c mod $ETH0 ipv4.method auto
sudo nmcli c mod $ETH1 connection.master br-prd connection.slave-type bridge
sudo nmcli c mod $ETH2 ipv4.method manual ipv4.addresses 192.168.101.$i/24
sudo nmcli c mod $ETH3 ipv4.method manual ipv4.addresses 192.168.102.$i/24

sudo nmcli c show

sudo nmcli c reload
sudo systemctl restart $UNIT
sleep $SLEEP

sudo nmcli c up bridge-br-prd
