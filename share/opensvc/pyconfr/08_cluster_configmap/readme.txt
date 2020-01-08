# remotely deploy using configmaps & namespaces

# on cXXn3 #

1/ unset any context
    om ctx unset

2/ inject configmap into cluster
    om ctx set root@${OSVC_CLUSTER_NAME}
    om prod/cfg/variables create
    om prod/cfg/variables add --key port --value 19090
    om preprod/cfg/variables create
    om preprod/cfg/variables add --key port --value 29090

3/ deploy web service in preprod environment
    # on the remote client (cXXn3)
    om ns1/svc/${OSVC_SVC1_NAME} print config --format json | om preprod/svc/${OSVC_SVC3_NAME} create --config=- --kw container#0.configs_environment=PORT=variables/port
    om preprod/svc/${OSVC_SVC3_NAME} unset --kw container#0.environment --kw env.port
    om preprod/svc/${OSVC_SVC3_NAME} print config
    om preprod/svc/${OSVC_SVC3_NAME} provision
    curl http://${OSVC_SVC3_NAME}:29090

4/ deploy web service in prod environment
    # on the remote client (cXXn3)
    om preprod/svc/${OSVC_SVC3_NAME} print config --format json | om prod/svc/${OSVC_SVC4_NAME} deploy --config=-
    curl http://${OSVC_SVC4_NAME}:19090
