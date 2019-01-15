#!/bin/bash

# user
getent passwd opensvc || {
	sudo useradd opensvc
	echo opensvc:opensvc | sudo chpasswd
}

getent group vagrant | grep -q opensvc || {
	sudo usermod -G vagrant opensvc
}
