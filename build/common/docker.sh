#!/bin/bash

# bugfixes

[[ -d /usr/libexec/docker ]] && {
    cd /usr/libexec/docker/
    [[ ! -L docker-runc ]] && sudo ln -s docker-runc-current docker-runc
    sudo grep -q 'PATH:/usr/libexec/docker' /etc/sysconfig/opensvc 2>/dev/null || {
	    echo "export PATH=\$PATH:/usr/libexec/docker" | sudo tee -a /etc/sysconfig/opensvc
    }
}

[[ -f /etc/oci-register-machine.conf ]] && {
    sudo sed -i -e "s/: false/: true/" /etc/oci-register-machine.conf
}

# disable docker iptables
[[ ! -f /etc/sysconfig/docker ]] && {
    [[ ! -d /etc/systemd/system/docker.service.d ]] && {
        echo "disable dockerd iptables"
        sudo mkdir -p /etc/systemd/system/docker.service.d
        echo -e "[Service]\nExecStart=\nExecStart=/usr/bin/dockerd -H fd:// --iptables=false" | sudo tee /etc/systemd/system/docker.service.d/disable-iptables.conf
    }
}

[[ -f /etc/sysconfig/docker-network ]] && {
    sudo sed -i 's/DOCKER_NETWORK_OPTIONS=.*/DOCKER_NETWORK_OPTIONS="--iptables=false"/' /etc/sysconfig/docker-network
}

sudo systemctl daemon-reload
sudo systemctl -q is-enabled docker.service || sudo systemctl -q enable docker.service
sudo systemctl restart docker.service

# install cni

[[ ! -d /opt/cni/bin ]] && {
    [[ -x /data/cni/cni.sh ]] && {
        echo "Installing CNI"
	/data/cni/cni.sh
    }
}



exit 0
