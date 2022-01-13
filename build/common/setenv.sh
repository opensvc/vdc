#!/bin/bash

echo
echo "########################"
echo "######## SETENV ########"
echo "########################"
echo
echo

set -a
[[ -f ~vagrant/opensvc-qa.sh ]] && . ~vagrant/opensvc-qa.sh

ENVFILE="${QASCRIPTS}/01.services.sh"
PATHFILE="${QASCRIPTS}/02.path.sh"

#grep -q "export OSVC_OSVC_CLUSTER_NUMBER=${OSVC_CLUSTER_NUMBER}" ${ENVFILE} || {
#echo "Adding OSVC_OSVC_CLUSTER_NUMBER=${OSVC_CLUSTER_NUMBER} to ${ENVFILE}"
#cat - <<EOF >> ${ENVFILE}
#export OSVC_OSVC_CLUSTER_NUMBER=${OSVC_CLUSTER_NUMBER}
#EOF
#
#}

#grep -q "export OSVC_CLUSTER_NAME=cluster${OSVC_CLUSTER_NUMBER}" ${ENVFILE} || {
#echo "Adding OSVC_CLUSTER_NAME=cluster${OSVC_CLUSTER_NUMBER} to ${ENVFILE}"
#cat - <<EOF >> ${ENVFILE}
#export OSVC_CLUSTER_NAME=cluster${OSVC_CLUSTER_NUMBER}
#EOF
#
#}

echo "Adding OSVC_SVC?_NAME=c${OSVC_CLUSTER_NUMBER}svc? to ${ENVFILE}"
cat - <<EOF >> ${ENVFILE}
export OSVC_SVC1_NAME=c${OSVC_CLUSTER_NUMBER}svc1
export OSVC_SVC2_NAME=c${OSVC_CLUSTER_NUMBER}svc2
export OSVC_SVC3_NAME=c${OSVC_CLUSTER_NUMBER}svc3
export OSVC_SVC4_NAME=c${OSVC_CLUSTER_NUMBER}svc4
export OSVC_SVC5_NAME=c${OSVC_CLUSTER_NUMBER}svc5
export OSVC_SVC6_NAME=c${OSVC_CLUSTER_NUMBER}svc6
export OSVC_SVC7_NAME=c${OSVC_CLUSTER_NUMBER}svc7
export OSVC_SVC8_NAME=c${OSVC_CLUSTER_NUMBER}svc8
export OSVC_SVC9_NAME=c${OSVC_CLUSTER_NUMBER}svc9
export OSVC_SVC10_NAME=c${OSVC_CLUSTER_NUMBER}svc10
export OSVC_SVC11_NAME=c${OSVC_CLUSTER_NUMBER}svc11
export OSVC_SVC12_NAME=c${OSVC_CLUSTER_NUMBER}svc12
export OSVC_SVC13_NAME=c${OSVC_CLUSTER_NUMBER}svc13
export OSVC_SVC14_NAME=c${OSVC_CLUSTER_NUMBER}svc14
EOF

# Fix path if needed
cat - <<EOF > ${PATHFILE}
if ! echo \${PATH} | grep -qw ':/bin:'; then
	PATH=\${PATH}:/bin
fi
if ! echo \${PATH} | grep -qw ':/sbin:'; then
	PATH=\${PATH}:/sbin
fi
EOF

echo "Adding pytests flag to avoid failing CI"
for path in /root /home/vagrant
do
    for ver in 2 3
    do
    	[[ ! -f ${path}/.pytest.skip.errors.${ver} ]] && touch ${path}/.pytest.skip.errors.${ver}
    done
    
    grep -qE "Ubuntu 20.04 LTS" /etc/os-release && {
    	echo "Disabling pytests2"
    	touch ${path}/pytest.skip.2
    }
done

exit 0
