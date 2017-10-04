#!/bin/bash

CMD="echo"

[[ $1 == "run" ]] && {
    CMD=""
}

for node in $(sudo nodemgr get --param cluster.nodes)
do
	echo
	echo "--------- Upgrading $node ---------"
	echo 
    $CMD sudo ssh $node yum -y upgrade /data/opensvc/rpms/current-1.9.rpm
done

