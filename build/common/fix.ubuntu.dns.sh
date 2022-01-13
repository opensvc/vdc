#!/bin/bash

echo
echo "#########################"
echo "######## FIX DNS ########"
echo "#########################"
echo

echo
echo "# before dns config"
sudo nmcli c show
echo
echo

echo "Switch Netplan to NetworkManager"
rm -f /etc/netplan/*
cat >| /etc/netplan/01-network-manager-all.yaml <<EOF
network:
  version: 2
  renderer: NetworkManager
EOF
sudo netplan generate
sudo netplan apply

echo "Setup Network Manager to configure resolver"
cat >| /etc/NetworkManager/conf.d/10-osvc-dns.conf <<EOF
[main]
dns=default
EOF

echo "Remove stub symlink /etc/resolv.conf => ../run/systemd/resolve/stub-resolv.conf"
rm -f /etc/resolv.conf

echo "Restart Network Manager"
systemctl restart NetworkManager
sleep 5

echo "Display /etc/resolv.conf contents"
cat /etc/resolv.conf

# load OSVC_ env variables
#. /etc/profile
#sudo nmcli con mod bridge-br-prd ipv4.dns 10.0.2.3
#sudo nmcli con mod bridge-br-prd ipv4.dns-search "vdc.opensvc.com opensvc.com"
#sudo nmcli c up bridge-br-prd
#sudo nmcli con mod ${OSVC_NIC0} ipv4.ignore-auto-dns true
#sudo nmcli c up ${OSVC_NIC0}

#echo "Disable DNS management through NetworkManager"
#echo -e "[main]\ndns=none" > /etc/NetworkManager/conf.d/no-dns.conf
#sudo systemctl restart NetworkManager

#echo "Disable systemd-networkd"
#sudo systemctl disable systemd-networkd
#sudo systemctl mask systemd-networkd
#sudo systemctl stop systemd-networkd

#echo "Disable systemd-resolved"
#sudo systemctl stop systemd-resolved.service
#sudo systemctl disable systemd-resolved.service

echo "Cleaning /etc/hosts"
cat /etc/hosts | grep -v `hostname -s` > /etc/hosts.clean
cp /etc/hosts.clean /etc/hosts

#echo "Building static /etc/resolv.conf"
#rm -f /etc/resolv.conf
#cat >| /etc/resolv.conf <<EOF
#nameserver 10.0.2.3
#options edns0
#EOF

#sudo systemctl stop systemd-networkd
#sudo systemctl disable systemd-networkd
#systemd-resolve --set-dns=10.0.2.3 --interface=eth0
#sudo systemctl reload-or-restart systemd-resolved
#sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
#sudo systemctl stop systemd-resolved.service
#sudo systemctl disable systemd-resolved.service
#sudo rm -f /etc/resolv.conf
#sudo echo nameserver 192.168.121.1 | tee /etc/resolv.conf
#sudo apt -y install resolvconf
#sudo echo nameserver 192.168.121.1 | tee /etc/resolvconf/resolv.conf.d/tail
#sudo ln -sf /run/resolvconf/resolv.conf /etc/resolv.conf
#resolvconf -u

echo
echo "# after dns config"
sudo nmcli c show
echo
echo
