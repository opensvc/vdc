#!/bin/bash

ifdown ens10
ifdown ens11
ifdown ens12
ifdown eth1
ifdown eth2
ifdown eth3

echo "source-directory /etc/network/interfaces.d" >/etc/network/interfaces

sudo apt install -y \
	network-manager \
	net-tools \
	bridge-utils \
	lvm2 \
	git \
	wget \
	python-requests \
	mdadm \
	sg3-utils \
	psmisc \
	iotop \
	python-crypto \
	htop

