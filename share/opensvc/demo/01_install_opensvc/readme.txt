# Package Install on user workstation

If internet access :
    wget -O opensvc.rpm https://repo.opensvc.com/rpms/current && yum -y install opensvc.rpm
else:
    yum -y install /data/opensvc/rpms/current-2.0.rpm


# register node

om node set --kw node.dbopensvc=https://collector
om node register --user user${OSVC_CLUSTER_NUMBER}@vdc.opensvc.com --app app10
