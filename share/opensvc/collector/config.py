server_timezone = "UTC"
actiond_workers = 5
dns_managed_zone = "vdc.opensvc.com"
refuse_anon_register = True
create_app_on_register = True
membership_on_register = [
    "AppManager",
    "GroupManager",
    "SelfManager",
    "NodeManager",
    "ProvisioningManager",
    "NodeExec",
    "CompExec",
    "CheckExec",
    "CheckRefresh",
    "DockerRegistriesManager",
    "DockerRegistriesPusher",
    "DockerRegistriesPuller",
    "RootPasswordExec",
    "QuotaManager",
    "ContextCheckManager",
    "ReportsManager",
    "UserManager",
    "SafeUploader",
    "TagManager",
    "FormsManager",
    "StorageManager",
    "DnsManager",
    "DnsOperator",
    "NetworkManager",
    "ObsManager",
    "CompManager",
]

