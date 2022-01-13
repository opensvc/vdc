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

[[ -x /usr/sbin/ntpdate ]] && {
	echo "Sync time with ntpdate"
	/usr/sbin/ntpdate -s time.chronos.fr
}

exit 0
