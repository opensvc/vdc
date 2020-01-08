# access the web gui

# on cXXn1
1/ generate the pkcs12 cert for user root
om system/usr/root pkcs12 > /tmp/root.pkcs12.pfx

2/ on laptop with browser, get the pfx file
scp root@cXXn1:/tmp/root.pkcs12.pfx $HOME/

3/ import pfx file into certificate repository

4/ connect to web gui

https://c${OSVC_CLUSTER_NUMBER}vip:1215

