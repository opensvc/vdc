#!/bin/bash

# user
sudo useradd opensvc
sudo usermod -G vagrant opensvc
echo opensvc:opensvc | sudo chpasswd

