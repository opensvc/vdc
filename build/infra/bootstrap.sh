#!/bin/bash

sudo svcmgr -s collector create --template /data/opensvc/templates/collector.template --provision
sudo svcmgr -s registry create --template /data/opensvc/templates/registry.template --provision

