#!/bin/bash

# yum
sudo yum-config-manager --disable CentOS\*
sudo yum-config-manager --add-repo file:///data/repos/centos/7/base
sudo yum-config-manager --add-repo file:///data/repos/centos/7/extras
sudo yum-config-manager --add-repo file:///data/repos/centos/7/updates
sudo yum-config-manager --add-repo file:///data/repos/epel/7
sudo yum-config-manager --add-repo file:///data/repos/elrepo/7
sudo yum-config-manager --setopt="gpgcheck=0" --save
