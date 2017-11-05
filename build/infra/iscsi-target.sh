#!/bin/bash

# drop all config + disk files
# sudo targetcli clearconfig confirm=true && rm -f /iscsi-disks/*.img

# list config
# sudo targetcli ls

DISKSREPO="/iscsi-disks"
HOSTLIST=/data/vdc.nodes

sudo yum -y install targetcli

[[ ! -d $DISKSREPO ]] && sudo mkdir $DISKSREPO

for node in $(cat $HOSTLIST | awk '{print $1}' | grep -v ^infra)
do
	# create quorum disk
	[[ ! -f $DISKSREPO/$node.disk.quorum.img ]] && {
	    sudo targetcli backstores/fileio create $node.dq $DISKSREPO/$node.disk.quorum.img 10M
	}

	# create data disks
	for i in 1 2 3 4 5
	do
	    [[ ! -f $DISKSREPO/$node.disk.data$i.img ]] && {
	        sudo targetcli backstores/fileio create $node.dd$i $DISKSREPO/$node.disk.data$i.img 1G
	    }
	done

	# 2 tgts per node
	for tgt in 1 2
	do
	    # create target
            sudo targetcli iscsi/ create iqn.2009-11.com.opensvc.srv:$node.storage.target.0$tgt
	    # map luns to targets
	    sudo targetcli iscsi/iqn.2009-11.com.opensvc.srv:$node.storage.target.0$tgt/tpg1/luns create /backstores/fileio/$node.dq
	    for i in 1 2 3 4 5
            do
		    sudo targetcli iscsi/iqn.2009-11.com.opensvc.srv:$node.storage.target.0$tgt/tpg1/luns create /backstores/fileio/$node.dd$i
            done
            # add host acl
	    sudo targetcli iscsi/iqn.2009-11.com.opensvc.srv:$node.storage.target.0$tgt/tpg1/acls create iqn.2009-11.com.opensvc.srv:$node.storage.initiator
	done

done

sudo targetcli saveconfig
sudo systemctl enable target.service
sudo systemctl start target.service
