#!/bin/bash

INVENTORY="/data/vdc/share/vdc.nodes"

declare -A subnets
subnets["192.168.100"]=""
subnets["192.168.101"]="-hb1"
subnets["192.168.102"]="-hb2"

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
    TIMESTAMP=$(date -u +%Y%m%d%H%M%S)
    cp -pf /etc/hosts /etc/hosts.$TIMESTAMP && {
        cat /etc/hosts.$TIMESTAMP | sed '/## OPENSVC VAGRANT LAB BEGIN ##/,/## OPENSVC VAGRANT LAB END ##/d' > /etc/hosts
    }
    find /etc -name \*hosts.2\* -ctime +7 -exec rm -f {} \;
}

clean_hosts
gen_data >> /etc/hosts
systemctl reload dnsmasq.service

