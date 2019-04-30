#!/bin/bash

set -a

echo "Updating /etc/hosts with vdc nodes records"

INVENTORY="/data/vdc/share/vdc.nodes"
TIMESTAMP=$(date -u +%Y%m%d%H%M%S)

declare -A subnets
subnets["192.168.100"]=""
subnets["192.168.101"]="-hb0"
subnets["192.168.102"]="-hb1"

[[ ! -f $INVENTORY ]] && {
	echo "error: vdc.nodes is missing. exiting"
	exit 1
}

function gen_data()
{
    # prepare new entries
    printf "## OPENSVC VAGRANT LAB BEGIN ##\n"
    cat $INVENTORY | while read alias index
    do
        for key in ${!subnets[@]};
        do
            printf "%s.%s\t%s%s\n" "$key" "$index" "$alias" "${subnets[$key]}"
        done
    done
    printf "## OPENSVC VAGRANT LAB END ##\n"
}

function clean_hosts()
{
    # remove old entries
    cp -pf /etc/hosts /etc/hosts.$TIMESTAMP && {
        cat /etc/hosts.$TIMESTAMP | sed '/## OPENSVC VAGRANT LAB BEGIN ##/,/## OPENSVC VAGRANT LAB END ##/d' > /etc/hosts
    }
    find /etc -name \*hosts.2\* -ctime +7 -exec rm -f {} \;
}

function distribute_data()
{
    find /data/vdc/build -name Vagrantfile | while read vagrantfile
    do
        tgt=$(dirname $vagrantfile)
	/bin/cp /data/vdc/share/vdc.nodes* $tgt/
    done
}

clean_hosts
gen_data > /data/vdc/share/vdc.nodes.hosts
cat /data/vdc/share/vdc.nodes.hosts >> /etc/hosts

distribute_data

OLDSUM=$(md5sum /etc/hosts.$TIMESTAMP | awk '{print $1}')
NEWSUM=$(md5sum /etc/hosts | awk '{print $1}')

[[ $OLDSUM != $NEWSUM ]] && {
    echo "Changes detected, restarting systemd-resolved"
    systemctl restart systemd-resolved.service
}

exit 0
