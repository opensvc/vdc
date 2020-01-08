#!/bin/bash

#wget https://github.com/containernetworking/cni/releases/download/v0.6.0/cni-amd64-v0.6.0.tgz
#wget https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz

set -a 

CNI_ROOT=/usr/libexec/cni
CNI_BIN=$CNI_ROOT/bin
CNI_BIN_PKG=/data/cni/cni-amd64-current.tgz
CNI_PLUGINS_PKG=/data/cni/cni-plugins-amd64-current.tgz

echo "Downloading https://github.com/containernetworking/cni/releases/download/v0.6.0/cni-amd64-v0.6.0.tgz"
echo "Downloading https://github.com/containernetworking/plugins/releases/download/v0.8.3/cni-plugins-amd64-v0.8.3.tgz"
echo "Creating install folder $CNI_BIN"
[[ ! -d $CNI_BIN ]] && sudo mkdir -p $CNI_BIN
cd $CNI_BIN && {
    echo "Extract CNI"
    sudo tar xzf $CNI_BIN_PKG
    echo "Extract CNI Plugins"
    sudo tar xzf $CNI_PLUGINS_PKG
}

exit 0
