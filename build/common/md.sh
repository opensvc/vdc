#!/bin/bash

echo
echo "####################"
echo "######## MD ########"
echo "####################"
echo

[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

for file in /etc/mdadm.conf /etc/mdadm/mdadm.conf
do
  test -f $file && {
      echo "File $file is found"
      grep -q '^AUTO -all' $file 2>/dev/null || {
          echo "Populating $file  with AUTO -all"
          echo "AUTO -all" >> $file
      }
  }
done

exit 0
