#!/bin/bash

echo
echo "#####################"
echo "######## SSH ########"
echo "#####################"
echo

echo "Customizing sshd config"
sudo sed -i -e "s/^PasswordAuthentication no/PasswordAuthentication yes/" /etc/ssh/sshd_config 
sudo sed -i -e "s/^GSSAPIAuthentication yes/GSSAPIAuthentication no/" /etc/ssh/sshd_config 

echo "Restarting sshd systemd unit"
sudo systemctl restart sshd

