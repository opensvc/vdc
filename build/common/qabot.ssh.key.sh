#!/bin/bash

echo
echo "#######################"
echo "######## QABOT ########"
echo "#######################"
echo

[[ ! -d /root/.ssh ]] && mkdir /root/.ssh

grep -q opensvc-qabot /root/.ssh/authorized_keys || {

cat - <<EOF >>/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbh065DQH64jyu2/8btyvmAcDZDdTPkcMnfF/CB1QQAWF+mfeq2Hb3xWEBAO5RIF1Yb2JJYIhJt8rv4zhpu8qkK9GkV5lhR68Ma1/ZXHCufYRAt6SfQZqW79hJGVDXC/tuDf+b+TNsZYPJrxFZZXkTszj4q7A3P4LGrdjnpbLL83DBaOIEKlwKBBUMLSMdi4s3G0rZJFDoeDJf3ng8TNT4N6wJidEHk7CMJZr8LIrMXLoUiZUylrFLYrOixZLnT8Az4Nf/GiHj/bDPKyFhqISQX70MSmcQ3Nsd3cGSbxAGXuy995+92qLxls6Ku1guTbFqYN8ev1XvGaxvzRz6/HeH opensvc-qabot
EOF

}

chmod 600 /root/.ssh/authorized_keys
