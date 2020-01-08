# Install & Form OpenSVC cluster

##############
# BOTH NODES #
##############

# install opensvc package
If internet access :
    wget -O opensvc.rpm https://repo.opensvc.com/rpms/current && yum -y install opensvc.rpm
else:
    yum -y install /data/opensvc/rpms/current-2.0.rpm


#########
# NODE1 #
#########

# set a fancy name to the cluster (optional, but best practice)
    om cluster set --kw cluster.name=${OSVC_CLUSTER_NAME}
    om cluster get --kw cluster.name
    om mon

# declare a communication channel between nodes
    om cluster set --kw hb#1.type=unicast
    om mon     # check new heartbeats threads using port 10000
    om cluster print config

# prepare cluster join command TO BE EXECUTED ON NODE2
    SECRET=$(om cluster get --kw cluster.secret)
    echo "om daemon join --node c${OSVC_CLUSTER_NUMBER}n1 --secret ${SECRET}"

# watch node2 join cluster
    om mon -w


#########
# NODE2 #
#########

# join node 1 to be included in the cluster
    # paste line from node1 here, it should looks like below
    # om daemon join --node cZZn1 --secret 4c77d40cbf7411e9a56a080027dfb17a

# watch other shell running 'om mon -w' on node1






