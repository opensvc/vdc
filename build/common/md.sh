#!/bin/bash

echo
echo "####################"
echo "######## MD ########"
echo "####################"
echo

grep -q '^AUTO -all' /etc/mdadm.conf 2>/dev/null || {
    echo "Populating /etc/mdadm.conf with AUTO -all"
    echo "AUTO -all" >>/etc/mdadm.conf
}
