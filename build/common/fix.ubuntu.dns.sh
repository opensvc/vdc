#!/bin/bash

echo "Switch Netplan to NetworkManager"
rm -f /etc/netplan/*
cat >| /etc/netplan/01-network-manager-all.yaml <<EOF
network:
  version: 2
  renderer: NetworkManager
EOF
sudo netplan generate

echo "Disable DNS management through NetworkManager"
echo -e "[main]\ndns=none" > /etc/NetworkManager/conf.d/no-dns.conf
sudo systemctl restart NetworkManager

echo "Disable systemd-networkd"
sudo systemctl disable systemd-networkd
sudo systemctl mask systemd-networkd
sudo systemctl stop systemd-networkd

echo "Disable systemd-resolved"
sudo systemctl stop systemd-resolved.service
sudo systemctl disable systemd-resolved.service

echo "Cleaning /etc/hosts"
cat /etc/hosts | grep -v `hostname -s` > /etc/hosts.clean
cp /etc/hosts.clean /etc/hosts

echo "Building static /etc/resolv.conf"
rm -f /etc/resolv.conf
cat >| /etc/resolv.conf <<EOF
nameserver 10.0.2.3
options edns0
EOF

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
