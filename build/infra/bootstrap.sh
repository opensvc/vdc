#!/bin/bash

echo "Manual steps"
echo "------------"
echo
echo "docker login registry.opensvc.com"
echo "sudo svcmgr -s collector create --template /data/opensvc/templates/collector.template"
echo "sudo svcmgr -s collector set --kw ip#1.ipdev={env.bridge} --kw ip#1.ipname={env.ipaddr} --kw ip#1.netmask={env.netmask} --kw ip#1.gateway={env.gateway} --kw ip#1.type=netns --kw ip#1.netns=container#0 --kw env.bridge=br-prd --kw env.ipaddr=192.168.100.9 --kw env.netmask=24 --kw env.gateway=192.168.100.1"
echo "sudo svcmgr -s collector provision"

echo "sudo svcmgr -s registry create --template /data/opensvc/templates/registry.template --provision"

