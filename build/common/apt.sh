#!/bin/bash

echo "source-directory /etc/network/interfaces.d" >/etc/network/interfaces

sudo apt install -y \
	network-manager \
	dnsutils \
	net-tools \
	bridge-utils \
	lvm2 \
	git \
	jq \
	wget \
	python-requests \
	python-crypto \
	mdadm \
	mlocate \
	sg3-utils \
	psmisc \
	iotop \
        docker.io \
	links \
	runc \
        sg3-utils \
	htop \
        psmisc \
	python3 python3-requests python3-crypto
