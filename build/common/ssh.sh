#!/bin/bash

echo
echo "#####################"
echo "######## SSH ########"
echo "#####################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

echo "Customizing sshd config"
sudo sed -i -e "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config 
sudo sed -i -e "s/^GSSAPIAuthentication yes/GSSAPIAuthentication no/" /etc/ssh/sshd_config 
sudo sed -i -e "s/^PermitRootLogin no/PermitRootLogin yes/" /etc/ssh/sshd_config

echo "Restarting sshd systemd unit"
type systemctl >> /dev/null 2>&1 && sudo systemctl restart sshd

grep -q FreeBSD /etc/os-release && {
    sudo service sshd restart
}

exit 0
