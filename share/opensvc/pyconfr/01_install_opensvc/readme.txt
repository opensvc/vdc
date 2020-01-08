# Package Install on user workstation

If internet access :
    wget -O opensvc.rpm https://repo.opensvc.com/rpms/current && yum -y install opensvc.rpm
else:
    yum -y install /data/opensvc/rpms/current-2.0.rpm


# Checks
- control presence of osvcd.py daemon
    ps aux|grep [o]svcd.py

- query daemon
    om mon


# logout / login from system to be sure to source OpenSVC environment
