#!/bin/bash

function make_link()
{
    pyver=$1
    [[ ! -f /usr/local/bin/$pyver ]] && {
        target=$(find /bin /usr/bin -type f -name python\* | grep -w $pyver | sort -nr | head -1)
        if [ ! -z $target ];
        then
            echo "Requested python $pyver : found target <$target>"
            ln -sf $target /opt/opensvc/bin/$pyver
        else
            echo "No target found for requested python $pyver"
        fi
    }
}

make_link python3
make_link python2

exit 0
