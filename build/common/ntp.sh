#!/bin/bash

[[ -x /usr/bin/timedatectl ]] && {
	timedatectl set-timezone CET
	timedatectl set-local-rtc 0
        timedatectl
}

exit 0
