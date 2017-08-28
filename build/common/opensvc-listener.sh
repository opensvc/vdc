#!/bin/bash

nodemgr --version 2>&1 | grep -q 1.9 && exit 0

cat - <<EOF >/etc/systemd/system/opensvc-actions@.service
[Unit]
Description=OpenSVC collector-queued actions handler

[Service]
ExecStart=-/usr/bin/nodemgr dequeue actions
EOF

cat - <<EOF >/etc/systemd/system/opensvc-actions.socket
[Unit]
Description=OpenSVC socket to receive collector notifications that actions are queued for the local agent

[Socket]
ListenStream=1214
Accept=yes
Service=opensvc-actions

[Install]
WantedBy=sockets.target
EOF

systemctl enable opensvc-actions.socket
systemctl restart opensvc-actions.socket

