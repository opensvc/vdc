#!/bin/bash

set -a

. /data/vdc/vdc.env

echo "Updating /etc/hosts with vdc nodes records"

TIMESTAMP=$(date -u +%Y%m%d%H%M%S)

# build subnets table
declare -A subnets
typeset -i idx=0

while [[ $idx -lt $VDC_CLUSTER_IDX ]]
do
    #ipstring="$ipstring,$netA.$idx.$cpt.1/24"
    subnets["${VDC_SUBNET_A}.${idx}.0"]=""
    subnets["${VDC_SUBNET_A}.${idx}.1"]="-hb1"
    subnets["${VDC_SUBNET_A}.${idx}.2"]="-hb2"
    let idx=$idx+1
done

[[ ! -f ${VDC_NODES} ]] && {
	echo "error: vdc.nodes is missing. exiting"
	exit 1
}

function gen_data()
{
    # prepare new entries
    printf "## OPENSVC VAGRANT LAB BEGIN ##\n"
    cat ${VDC_NODES} | while read nodename cluid ip
    do
	#echo --- $nodename --- $cluid --- $ip
        for key in ${!subnets[@]}
        do
	    [[ $key == ${VDC_SUBNET_A}.${cluid}.* ]] && {
                printf "%s.%s\t%s%s\n" "$key" "$ip" "$nodename" "${subnets[$key]}"
            }
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
    find /data/vdc/build -maxdepth 2 -name Vagrantfile | while read vagrantfile
    do
        tgt=$(dirname $vagrantfile)
	/bin/cp /data/vdc/share/vdc.nodes* $tgt/
	/bin/cp /data/vdc/vdc.env $tgt/
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
