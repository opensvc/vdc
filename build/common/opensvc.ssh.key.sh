#!/bin/bash

echo
echo "##################################"
echo "######## OPENSVC SSH KEYS ########"
echo "##################################"
echo

[[ ! -d /root/.ssh ]] && mkdir /root/.ssh

grep -q 'opensvc-qabot' /root/.ssh/authorized_keys || {

cat - <<EOF >>/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbh065DQH64jyu2/8btyvmAcDZDdTPkcMnfF/CB1QQAWF+mfeq2Hb3xWEBAO5RIF1Yb2JJYIhJt8rv4zhpu8qkK9GkV5lhR68Ma1/ZXHCufYRAt6SfQZqW79hJGVDXC/tuDf+b+TNsZYPJrxFZZXkTszj4q7A3P4LGrdjnpbLL83DBaOIEKlwKBBUMLSMdi4s3G0rZJFDoeDJf3ng8TNT4N6wJidEHk7CMJZr8LIrMXLoUiZUylrFLYrOixZLnT8Az4Nf/GiHj/bDPKyFhqISQX70MSmcQ3Nsd3cGSbxAGXuy995+92qLxls6Ku1guTbFqYN8ev1XvGaxvzRz6/HeH opensvc-qabot
EOF

}

grep -q 'OPENSVC-CVI' /root/.ssh/authorized_keys || {

cat - <<EOF >>/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDPiTjBH9tZI59Y5rE/6P90ATF/RT4LU53oBcViBVi/P1tyfCMex5lTuiwOpPEgA6Rvccj7PDQVDzP6IJXBlUgWuVezLMKJoYLVlZahvMTei1l1x9a6nc0eusEfDUYg/+CzTpRBptKyCc9suUZT8AlnSbsxS1TXxe30RAfpT7eSlPw2squGUM3Unaq/dL0JKMBptUMSas8k2b+rdcZeUNPZRhgaovo2AdBoEZi4nHyLJB37mi4Eevu+sAtIcWpUvEicOaH4yKp1n4EXddO19SdLcpOZ59UnJkwzJQjq6kaAMJ8Oyivpd5QTNmmZ86aiZeZP7bBlQLHFovjbYvfEJ0BSJqZoKhbS0kRSt+Bq4Vs54GTGCIBx+pTg7l30qOdgO9fvbGRRnH/Uh/G1ba9Mz611K3mdWcW5vhASX/Hc0bpl+1LuhnQp8erpQq9kXQ6eLlHSWmXfFZwlOLb5Sshy9ov8SqK7wa4htJOS+mpq2OLJ9vLQdI1mq0s6OgQbI+DKlh9bLYqhx1qrqw83wuweAYu14Lhb40JOEpjCxrBix7yvrONpF8H0hn0Sp4dwgrQaY3wbXW62t69iegsQ/MgQrT9gdt4Yif3yzKvu10QGYwFIHDZBEkaif82Z/zQiMQPMpUzLPfci3p0Eew+pB+pglhkHOxGiCV9abcZDAO8o6mBHlw== OPENSVC-CVI
EOF

}

grep -q 'OPENSVC-AVN' /root/.ssh/authorized_keys || {

cat - <<EOF >>/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAt/dDaRZwk4ggjx++FKyDLVz2VkWyoeEQ6IU2oMZsnY1BOK1RNpQi6Pb2I35yN1WWPTxY+3UtfVHJLJ08IIxEeFV8dikGjxsHz0kMSILX/SyJ7XfEl9N9bvOER3bldGDc8WIjUhWJCneCSqQhndqLELL63um0DPny/Bm3vWsFHAr7z9U2evpTLvGlrCMxKLxF70pXLwPZ+BlOFZtyHjGqe6COlDNe0UZdzIvol+KJNM4SEjtWon/BGO8MhBrG05bJbB8nG3UjOmEpQvxa6DqiF7/l5ro/M03hhJkQs7GVbhbMef0mjI2gjZSQES6NC3TTdtNBdjrKGrciA54jp9+YfP7y8AcbtKU+8WwcK2Tt5R/+krzD3rZ5E3ys6Hs023Xej+IQlddSj/qlHRYWhze5iWE3jlliTo9PTH84vToo47lcJob2dHOKIunl7An9aqQq0U3j8JNksJUP4HGMG0X9l13vByhIZ8jBRYKnr6t01HSVMTpVq/5mVeH3TG1HFZOZ0kUVs7C9XVr7auwWDaeHKbWKp3KTBpDcg//NgLL6qQkbtgkPtjyXOVRCyxsqktU5T98v1DWBFefMQdKgSM5mh/7ZVKCO03f6OgMFhntfdwOB1LCaxN4Urg6wIHT4yvIvIi5wpo0Iu/pNT+2CJLQcVC4CMsucBe6Z4r+eJn7RUR8= OPENSVC-AVN
EOF

}

grep -q 'OPENSVC-GMT' /root/.ssh/authorized_keys || {

cat - <<EOF >>/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGCY93/GPl3pHwfma3/ikFB5pcyeiBif+LwuYA3dm2qXxzdXP3CM/P1mdfEw2JvcGuKAHI3gSaW8fm+w5T1BFF7sT8/Wj/jj2xV2S9VAadwCjVCUKrDG0AatQlE7bmvjeloCOyDxeFiiulNO/a4x5gxif7VcpMzd8emNC7viOxjaroIi4qQxs4NOx4UvlBxGWP480BV2kvAJdzU/WYJzmVdZwb1q7gyrcfNCWWl5y7g+K5qttrNPV8zluoNVMIpvujfMf6ssauaLQcP9qzifvrkx4jWus2qb6GjMiKXrZNQUuJlzxxlDlNhZiwhInPp52CoSzqSE/tBsTRF6iID8F3 OPENSVC-GMT
EOF

}

grep -q 'OPENSVC-SGF' /root/.ssh/authorized_keys || {

cat - <<EOF >>/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCxuaDHXCPy6wXH0rLOaNuHwnPeKB8TCBXXc0U877pee+uM2uB5o+0KJ5EAaVpqVYlcL4ZFZnQBeG97e7uwXqSvDaGWZXBlQBShNKibG9MoqOGmVQF3q8k3DQjBcX11fqIEe/zL1ySKu6s6lmmurzc/aJcTZ/eTHXa+bJTAat8WRZFdNiP78L0i3SoaY3J44dlFNN9puF8ZBXT/jLU74seqJHANlQxQIbikYp2rtHoiV75eeMtNbaLhZfD5Y3yBYBU0/ufzHA7mntI5XEX7Vxb0pSLPTUCFBLFVggAWiU3ug0YZ0ENzvZ8n672zeGw1vG3ZdcLdCwmQzObdGh/bZpYd OPENSVC-SGF
EOF

}

chmod 600 /root/.ssh/authorized_keys
