Create, populate, start a local opensvc service
-----------------------------------------------

1/ create empty service
    om ${OSVC_SVC1_NAME} create
    om ${OSVC_SVC1_NAME} print config		# display service config
    om ${OSVC_SVC1_NAME} print status -r

2/ add ip resource
    ping -c 1 ${OSVC_SVC1_NAME}   # should not ping
    om ${OSVC_SVC1_NAME} set --kw ip#0.ipname={env.ipname} --kw ip#0.ipdev=br-prd --kw ip#0.check_carrier=false --kw env.ipname={svcname}
    om ${OSVC_SVC1_NAME} print config		# display service config
    om mon   # display cluster status

3/ start service with single ip
    om ${OSVC_SVC1_NAME} print status -r
    om ${OSVC_SVC1_NAME} start --local
    ping -c 1 ${OSVC_SVC1_NAME}   # ping should be ok
    ip addr show dev br-prd
    om ${OSVC_SVC1_NAME} print status -r
    om ${OSVC_SVC1_NAME} print config --format json
    om mon
    om ${OSVC_SVC1_NAME} stop --local

4/ add docker resource
    # first declare container
    om ${OSVC_SVC1_NAME} set --kw container#0.type=docker --kw container#0.image={env.image} --kw container#0.hostname={svcname} --kw container#0.rm=true --kw container#0.tty=true --kw env.image=helloworld:${OSVC_CLUSTER_NAME}

    # second change ip setup to configure container namespace instead of main system network namespace
    om ${OSVC_SVC1_NAME} set --kw ip#0.type=netns --kw ip#0.netns=container#0 
    om ${OSVC_SVC1_NAME} print config          # display service config

5/ start service with docker container
    om ${OSVC_SVC1_NAME} print status -r
    om ${OSVC_SVC1_NAME} start --local
    ping -c 1 ${OSVC_SVC1_NAME}   # ping should be ok
    ip addr show dev br-prd  # ip is not on hypervisor, but in the container network namespace
    om ${OSVC_SVC1_NAME} docker exec -it ${OSVC_SVC1_NAME}.container.0 ip a     # ip is configured in network namespace

6/ test dockerized web service on port 80
    curl http://${OSVC_SVC1_NAME}

7/ modify listening port
    om ${OSVC_SVC1_NAME} set --kw container#0.environment=PORT={env.port} --kw env.port=8080
    om ${OSVC_SVC1_NAME} print config          # display service config

8/ test dockerized web service on port 8080
    om ${OSVC_SVC1_NAME} restart
    curl http://${OSVC_SVC1_NAME}:8080

9/ stop local service
    om ${OSVC_SVC1_NAME} stop --local
