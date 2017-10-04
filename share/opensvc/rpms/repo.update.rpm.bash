#!/bin/bash

CMD="echo"

[[ $1 == "run" ]] && {
    CMD=""
}


TS=$(date +%Y%m%d%H%M%S)

for ver in 1.8 1.9
do
    $CMD cp -pf current-${ver} ${TS}.${ver}
    $CMD curl -o current-${ver} https://repo.opensvc.com/rpms/${ver}/current
    $CMD ln -sf current-${ver} current-${ver}.rpm
done

