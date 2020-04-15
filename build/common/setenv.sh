#!/bin/bash

echo
echo "########################"
echo "######## SETENV ########"
echo "########################"
echo
echo

ENVFILE=/etc/profile.d/sh.local

CLUSTER_NUMBER=$(grep -w ^$HOSTNAME /vagrant/vdc.nodes | sort -u | awk '{print $2}')

grep -q "export OSVC_CLUSTER_NUMBER=${CLUSTER_NUMBER}" ${ENVFILE} || {
echo "Adding OSVC_CLUSTER_NUMBER=${CLUSTER_NUMBER} to ${ENVFILE}"
cat - <<EOF >> ${ENVFILE}
export OSVC_CLUSTER_NUMBER=${CLUSTER_NUMBER}
EOF

}

grep -q "export OSVC_CLUSTER_NAME=cluster${CLUSTER_NUMBER}" ${ENVFILE} || {
echo "Adding OSVC_CLUSTER_NAME=cluster${CLUSTER_NUMBER} to ${ENVFILE}"
cat - <<EOF >> ${ENVFILE}
export OSVC_CLUSTER_NAME=cluster${CLUSTER_NUMBER}
EOF

}

grep -q "export OSVC_SVC1_NAME=c${CLUSTER_NUMBER}svc1" ${ENVFILE} || {
echo "Adding OSVC_SVC?_NAME=c${CLUSTER_NUMBER}? to ${ENVFILE}"
cat - <<EOF >> ${ENVFILE}
export OSVC_SVC1_NAME=c${CLUSTER_NUMBER}svc1
export OSVC_SVC2_NAME=c${CLUSTER_NUMBER}svc2
export OSVC_SVC3_NAME=c${CLUSTER_NUMBER}svc3
export OSVC_SVC4_NAME=c${CLUSTER_NUMBER}svc4
export OSVC_SVC5_NAME=c${CLUSTER_NUMBER}svc5
export OSVC_SVC6_NAME=c${CLUSTER_NUMBER}svc6
export OSVC_SVC7_NAME=c${CLUSTER_NUMBER}svc7
export OSVC_SVC8_NAME=c${CLUSTER_NUMBER}svc8
export OSVC_SVC9_NAME=c${CLUSTER_NUMBER}svc9
EOF

}

# Fix path if needed
cat - <<EOF > /etc/profile.d/add.bin.sbin.to.path.sh
if ! echo \${PATH} | grep -qw ':/bin:'; then
	PATH=\${PATH}:/bin
fi
if ! echo \${PATH} | grep -qw ':/sbin:'; then
	PATH=\${PATH}:/sbin
fi
EOF

exit 0
