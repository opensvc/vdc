#!/bin/bash

echo
echo "#####################"
echo "######## NTP ########"
echo "#####################"
echo

[[ -x /usr/bin/timedatectl ]] && {
	echo "Configuring NTP with timedatectl"
	timedatectl set-timezone CET
	timedatectl set-local-rtc 0
        timedatectl
}

exit 0
