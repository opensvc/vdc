# deploy cluster dns services
# server + forwarder
# needed to serve containers records running in autoscaling mode

1/ deploy dns setup
om cluster set --kw cluster.dns="10.${OSVC_CLUSTER_NUMBER}.0.11 10.${OSVC_CLUSTER_NUMBER}.0.12"
om cluster get --kw cluster.dns
check that new dns thread appeared
echo '{"method": "list", "parameters": {"zonename": "cluster10."}}' | sudo socat - unix://var/lib/opensvc/dns/pdns.sock | jq

2/ deploy dns service
om system/svc/dns create --config /data/opensvc/templates/odns.conf
om system/svc/dns set --kw container#1.run_args+="-v /etc/vdc.nodes.hosts:/vdc.nodes.hosts:ro" --kw container#1.run_command+="--etc-hosts-file=/vdc.nodes.hosts --export-etc-hosts"
om system/svc/dns provision --wait

3/ query dns
host -t A www.google.com 10.${OSVC_CLUSTER_NUMBER}.0.11
host -t A ${OSVC_SVC2_NAME} 10.${OSVC_CLUSTER_NUMBER}.0.11

4/ add internal ip resource
om ${OSVC_SVC2_NAME} set --kw ip#1.type=cni --kw ip#1.network=default --kw ip#1.restart=1
om ${OSVC_SVC2_NAME} restart --rid container#0

5/ add expose & check new SRV record
om ${OSVC_SVC2_NAME} set --kw ip#1.expose={env.port}/tcp
host -t SRV _9090._tcp.${OSVC_SVC2_NAME}.ns1.svc.${OSVC_CLUSTER_NAME} 10.${OSVC_CLUSTER_NUMBER}.0.11
dig +noall +answer cluster10. AXFR @10.${OSVC_CLUSTER_NUMBER}.0.11 -p 5300
