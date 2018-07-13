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

	# create local data disks
	for i in 0 1 2 3 4
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
	    for i in 0 1 2 3 4
            do
		  sudo targetcli iscsi/iqn.2009-11.com.opensvc.srv:$node.storage.target.0$tgt/tpg1/luns create /backstores/fileio/$node.dd$i
            done
            # add host acl
	    sudo targetcli iscsi/iqn.2009-11.com.opensvc.srv:$node.storage.target.0$tgt/tpg1/acls create iqn.2009-11.com.opensvc.srv:$node.storage.initiator
	done

done

for cluster in $(cat $HOSTLIST | grep -E "^node-.*-.|^qatest.*-.*-." | awk '{print $1}' | awk -F'-' '{print $2}'| sort -u)
do
	# create quorum disk
	[[ ! -f $DISKSREPO/cluster-$cluster.disk.quorum.img ]] && {
	    sudo targetcli backstores/fileio create cluster-$cluster.dq $DISKSREPO/cluster-$cluster.disk.quorum.img 10M
	}

	# create shared data disks
	for i in 0 1 2 3 4 5
	do
	    [[ ! -f $DISKSREPO/cluster-$cluster.disk.data$i.img ]] && {
	        sudo targetcli backstores/fileio create cluster-$cluster.dd$i $DISKSREPO/cluster-$cluster.disk.data$i.img 1G
	    }
	done

        for node in $(cat $HOSTLIST | grep -E "^node-$cluster-.|^qatest.*-$cluster-." | awk '{print $1}')
        do
	    for tgt in 1 2
	    do
		# present cluster quorum disk to host scsi lun 20
	        sudo targetcli iscsi/iqn.2009-11.com.opensvc.srv:$node.storage.target.0$tgt/tpg1/luns create /backstores/fileio/cluster-$cluster.dq 20
		# present shared luns starting at host scsi lun 10
	        for i in 0 1 2 3 4 5
                do
		    let lun=10+$i
		    sudo targetcli iscsi/iqn.2009-11.com.opensvc.srv:$node.storage.target.0$tgt/tpg1/luns create /backstores/fileio/cluster-$cluster.dd$i $lun
                done
            done
        done
done

# create massively shared quorum disk
[[ ! -f $DISKSREPO/all.cluster.disk.quorum.img ]] && {
    sudo targetcli backstores/fileio create cluster-all.dq $DISKSREPO/all.cluster.disk.quorum.img 10M
}

for node in $(cat $HOSTLIST | grep ^node | awk '{print $1}')
do
    for tgt in 1 2
    do
	# present cluster quorum disk to host scsi lun 30
        sudo targetcli iscsi/iqn.2009-11.com.opensvc.srv:$node.storage.target.0$tgt/tpg1/luns create /backstores/fileio/cluster-all.dq 30
    done
done

sudo targetcli saveconfig
sudo systemctl enable target.service
sudo systemctl start target.service
