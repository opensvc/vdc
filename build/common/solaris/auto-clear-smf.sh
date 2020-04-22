#!/bin/ksh -p

echo "Install custom opensvc-clear-smf to clear /lib/svc/method/fs-local transiant failure during boot"
echo "Because /export/home/vagrant may be busy"

SMF_CLEAR_CMD='/root/opensvc-clear-smf.sh'
DELAY=5
PERIOD=30
JITTER=5

cat > $SMF_CLEAR_CMD <<'EOF'
#!/bin/ksh -p

AUTO_CLEAR_SVCS="svc:/system/filesystem/local:default"

for svc in $AUTO_CLEAR_SVCS
do
        [ "$(svcs -H -o state $svc)" != maintenance ] && continue
        echo "service $svc is in maintenance, try svcadm clear $svc"
        svcadm clear $svc
        echo "sleep 2"
        echo "svcs -p $svc"
        svcs -p $svc
done

EOF

chmod +x $SMF_CLEAR_CMD

cat > /tmp/opensvc-clear-smf.xml <<EOF
<?xml version='1.0'?>
<!DOCTYPE service_bundle SYSTEM '/usr/share/lib/xml/dtd/service_bundle.dtd.1'>
<service_bundle type='manifest' name='export'>
        <service name='opensvc/clear-smf' type='service' version='0'>
    <create_default_instance enabled='true' complete='true'/>
    <single_instance/>
    <dependency name='single-user' grouping='require_all' restart_on='none' type='service'>
      <service_fmri value='svc:/milestone/single-user'/>
    </dependency>

                <periodic_method
                period='$PERIOD'
                delay='$DELAY'
                jitter='$JITTER'
                exec='$SMF_CLEAR_CMD'
                timeout_seconds='0'>
                    <method_context>
                        <method_credential user='root' group='root' />
                    </method_context>
            </periodic_method>
    <stability value='Unstable'/>
    <template>
      <common_name>
        <loctext xml:lang='C'>automatic clear smf failures</loctext>
      </common_name>
    </template>
  </service>
</service_bundle>
EOF

svccfg import /tmp/opensvc-clear-smf.xml


