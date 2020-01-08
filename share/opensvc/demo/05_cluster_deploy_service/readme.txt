# remotely deploy web service on cluster

# on cXXn3 #

1/ unset any context
    om ctx unset

2/ try to deploy web service as usr1
    # on the remote client (cXXn3)
    om ${OSVC_SVC1_NAME} print config --format json | ( om ctx set usr1@${OSVC_CLUSTER_NAME} && om ns1/svc/${OSVC_SVC2_NAME} deploy --config=- --kw env.port=9090 --kw orchestrate=ha --kw nodes=* --kw sync#i0.disable=true)
    # fail due to lack of privileges

3/ try to deploy web service as root
    # on the remote client (cXXn3)
    om ${OSVC_SVC1_NAME} print config --format json | ( om ctx set root@${OSVC_CLUSTER_NAME} && om ns1/svc/${OSVC_SVC2_NAME} deploy --config=- --kw env.port=9090 --kw orchestrate=ha --kw nodes=* --kw sync#i0.disable=true)

4/ check service
    om ctx set usr1@${OSVC_CLUSTER_NAME}
    om ns1/svc/${OSVC_SVC2_NAME} print status -r --node c${OSVC_CLUSTER_NUMBER}n1
    om ns1/svc/${OSVC_SVC2_NAME} print status -r --node c${OSVC_CLUSTER_NUMBER}n2
    curl http://${OSVC_SVC2_NAME}:9090

5/ relocate service on other node
    om ns1/svc/${OSVC_SVC2_NAME} switch
    curl http://${OSVC_SVC2_NAME}:9090
