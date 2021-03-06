#!/bin/bash

echo
echo "##################################"
echo "######## OPENSVC SSH KEYS ########"
echo "##################################"
echo

[[ ! -d /root/.ssh ]] && mkdir /root/.ssh && touch /root/.ssh/authorized_keys

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

grep -q 'fCa6h OPENSVC-SGF' /root/.ssh/authorized_keys || {

cat - <<EOF >>/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzMv/8c3e0WG7swC1z7WrxVa6NXipiI3yXFc9OFKpXAwgdnULbP0y0z+2w8sXgr7aEJ2pRFkAS+LDS5XKhNvNsL/vTsU96tiI+6o7IMXJUSdWlSR3nb08Ah/RpnfZGvJV3U61vswuVv/s0h9FokktTjK6DtOp4RzsUg6WkRWVPDuf5ME6ESFIx1IQhf73LUVjktyvfzN+rDFtVZwePmoVdIRRkh6gSGXXBixbX8Ff+0VOvqPPMQuAXUaXrTAFEs2dgv0+8SYEUJ15e9duJAiSo+U4XG9WBiA9kSEBk1b5BpE+ksRZpKvzHz7vUE5vZoB7HX1EdaaI7edPGFOpfCa6h OPENSVC-SGF
EOF

}

grep -q 'JnPm5i OPENSVC-CGN' /root/.ssh/authorized_keys || {

cat - <<EOF >>/root/.ssh/authorized_keys
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKTEoNNf0l/W3ItpaOkEjssrNU1KGkGyJ3WCo+JnPm5i OPENSVC-CGN
EOF

}

chmod 600 /root/.ssh/authorized_keys

[[ ! -f /root/.ssh/authorized_keys.install ]] && {
	cp /root/.ssh/authorized_keys /root/.ssh/authorized_keys.install
}
