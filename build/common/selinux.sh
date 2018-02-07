#!/bin/bash

sudo setenforce 0
sudo sed -i -e "s/^SELINUX=enforcing/SELINUX=disabled/" /etc/sysconfig/selinux

