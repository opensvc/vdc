# access cluster web interface

# on cXXn1 #
------------

# openid server url = https://keycloakvdc.opensvc.com:8443/auth/realms/clusters/.well-known/openid-configuration

1/ add openid provider url in cluster configuration
    om cluster set --kw listener.openid_well_known='https://keycloakvdc.opensvc.com:8443/auth/realms/clusters/.well-known/openid-configuration'

# on local laptop #
-------------------

2/ open url https://c${OSVC_CLUSTER_NUMBER}vip.vdc.opensvc.com:1215

3/ when prompted, select "OPENID" and fill in login "user${OSVC_CLUSTER_NUMBER}" (same password)




















##########################################
# FIREFOX : importing certificate with command line

a) identify your firefox profile
MZPROFILE=$(ls -1d $HOME/.mozilla/firefox/*.default)

b) list current certificates (optional)
certutil -L -d ${MZPROFILE}

c) import cert
pk12util -d ${MZPROFILE} -i $HOME/root.${OSVC_CLUSTER_NAME}.pfx
  # fill in the password used at time of pkcs12 certificate creation

##########################################
# CHROME : importing certificate with command line

a) list current certificates (optional)
certutil -L -d sql:$HOME/.pki/nssdb

b) import cert
pk12util -i path/to/bundle.p12 -d sql:$HOME/.pki/nssdb 
