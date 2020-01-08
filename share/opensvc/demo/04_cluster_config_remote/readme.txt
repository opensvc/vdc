# Configure cluster remote management features

# NODE1 #

1/ Create Cluster Root Certification Authority (stored as an Opensvc secret)
    
    om system/sec/ca-${OSVC_CLUSTER_NAME} create
    om system/sec/ca-${OSVC_CLUSTER_NAME} set --kw o=DEMO --kw c=fr
    om system/sec/ca-${OSVC_CLUSTER_NAME} gen cert 		# generate ssl certificates

    om system/sec/ca-${OSVC_CLUSTER_NAME} print config
    om system/sec/ca-${OSVC_CLUSTER_NAME} keys			# display keys stored in the secret

2/ Create Cluster listener certificate

    om system/sec/cert-${OSVC_CLUSTER_NAME} create --kw ca=system/sec/ca-${OSVC_CLUSTER_NAME} --kw cn=c${OSVC_CLUSTER_NUMBER}vip
    om '*/sec/*' ls     # list cluster secrets

3/ Deploy vip service (used by end user to connect the cluster)
    om cluster set --kw cluster.vip=10.${OSVC_CLUSTER_NUMBER}.0.20/24@br-prd
    om mon -i 1    # check service live deployment
    ping -c1 c${OSVC_CLUSTER_NUMBER}vip

4/ Test vip service failover
    om system/svc/vip switch
    om mon -i 1    # check service live relocation to other node
    om system/svc/vip giveback

5/ Create cluster users root and usr1
    om system/usr/root create
    om system/usr/usr1 create
    om '*/usr/*' ls     # list cluster users

6/ Grant rights to users
    # grant root user all rights
    om system/usr/root set --kw grant+=root
    om system/usr/root get --kw grant

    # grant usr1 user lower rights
    om system/usr/usr1 set --kw grant+=squatter       # 'squatter' role allow to create new namespaces
    om system/usr/usr1 set --kw grant+=admin:ns1      # usr1 has 'admin' role in namespace 'ns1'
    om system/usr/usr1 set --kw 'grant+=guest:*'      # usr1 has 'guest' role in all namespaces
    om system/usr/usr1 get --kw grant

7/ Extract cluster CA certificate to import into remote client
    # on the cluster
    om system/sec/ca-${OSVC_CLUSTER_NAME} decode --key certificate_chain > /tmp/${OSVC_CLUSTER_NAME}-ca.pem

    # on the remote client (cXXn3)
    # put file content in file ~/.opensvc/${OSVC_CLUSTER_NAME}-ca.pem
    mkdir ~/.opensvc
    scp root@c${OSVC_CLUSTER_NUMBER}n1:/tmp/${OSVC_CLUSTER_NAME}-ca.pem ~/.opensvc/${OSVC_CLUSTER_NAME}-ca.pem
    ls -l ~/.opensvc

8/ Extract user certificates to import into remote client
    # on the cluster
    om system/usr/usr1 fullpem > /tmp/${OSVC_CLUSTER_NAME}-usr1.full.pem
    om system/usr/root fullpem > /tmp/${OSVC_CLUSTER_NAME}-root.full.pem

    # on the remote client (cXXn3)
    paste usr1 file content in file ~/.opensvc/${OSVC_CLUSTER_NAME}-usr1.full.pem
    paste root file content in file ~/.opensvc/${OSVC_CLUSTER_NAME}-root.full.pem
    scp root@c${OSVC_CLUSTER_NUMBER}n1:/tmp/${OSVC_CLUSTER_NAME}-*.full.pem ~/.opensvc/

9/ Declare the remote users
    # on the remote client (cXXn3)
    om ctx user create --name usr1@${OSVC_CLUSTER_NAME} --client-certificate ~/.opensvc/${OSVC_CLUSTER_NAME}-usr1.full.pem 
    om ctx user create --name root@${OSVC_CLUSTER_NAME} --client-certificate ~/.opensvc/${OSVC_CLUSTER_NAME}-root.full.pem
    cat ~/.opensvc/config

10/ Declare the remote cluster
    # on the remote client (cXXn3) 
    om ctx cluster create --name ${OSVC_CLUSTER_NAME} --server=tls://c${OSVC_CLUSTER_NUMBER}vip:1215 --certificate-authority ~/.opensvc/${OSVC_CLUSTER_NAME}-ca.pem
    cat ~/.opensvc/config

11/ Declare the new contexts
    # on the remote client (cXXn3)
    om ctx create --name usr1@${OSVC_CLUSTER_NAME} --user usr1@${OSVC_CLUSTER_NAME} --cluster ${OSVC_CLUSTER_NAME}
    om ctx create --name root@${OSVC_CLUSTER_NAME} --user root@${OSVC_CLUSTER_NAME} --cluster ${OSVC_CLUSTER_NAME}
    cat ~/.opensvc/config

12/ switch to the usr1 context
    # on the remote client (cXXn3)
    om mon
    om ctx set usr1@${OSVC_CLUSTER_NAME}
    om mon
   
13/ try to failover service vip
    # on the remote client (cXXn3)
    om system/svc/vip switch
