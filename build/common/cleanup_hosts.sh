#!/bin/bash

echo
echo "#################"
echo "# cleanup hosts #"
echo "#################"
echo

echo "Ensure hosts does not contain $(uname -n) for 127.0.0.1 ..."
if [ "$(uname)" = "SunOS" ] ; then
   HOST_FILE=/etc/inet/hosts
else
   HOST_FILE=/etc/hosts
fi

# sed sux in freebsd
#sudo sed -i  -e 's/^127.0.0.1\s.*$/127.0.0.1 localhost/g' -e 's/127.0.1.1\s.*$/127.0.1.1 localhost-1/g' ${HOST_FILE}

sudo cp ${HOST_FILE} ${HOST_FILE}.install
sudo cat ${HOST_FILE}.install | grep -v '127.0' > ${HOST_FILE}
echo '127.0.0.1 localhost' >> ${HOST_FILE}
echo '127.0.1.1 localhost-1' >> ${HOST_FILE}
