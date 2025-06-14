domain_name = "infra"
team_name   = "cloudops"

#Policy TFVars
policy_initiative_name     = "global-policies"
global_management_group_id = "/providers/Microsoft.Management/managementgroups/e7be7e04-0043-442e-afa2-2949a3a3c134"
prod_management_group_id   = "/providers/Microsoft.Management/managementgroups/mg-blackstream-prod"

#Networking
wan_name = "prod-wan-blackstream-core-eau"
wan_hubs = {
  "WAN-Hub-Melbourne" = {
    address_prefix = "10.0.0.0/22"
  }
}

hub_connections = {
  "hub-connection-ng-dev" = {
    hub_name = "WAN-Hub-Melbourne"
    vnet_id  = "/subscriptions/75d2fa14-67cf-41aa-9717-875861f4f0d7/resourceGroups/dev-rg-ng-shared-infra-eau/providers/Microsoft.Network/virtualNetworks/dev-vnet-ng-shared-eau"
  }
  "hub-connection-ng-dev-ntrc" = {
    hub_name = "WAN-Hub-Melbourne"
    vnet_id  = "/subscriptions/75d2fa14-67cf-41aa-9717-875861f4f0d7/resourceGroups/dev-rg-ng-ntrc-shared-eau/providers/Microsoft.Network/virtualNetworks/dev-vnet-ng-ntrc-eau"
  }
  "hub-connection-core-vnet" = {
    hub_name = "WAN-Hub-Melbourne"
    vnet_id  = "/subscriptions/d877ef00-ea85-4a82-816c-b437fb7b1ebc/resourceGroups/rg-core-infra-network/providers/Microsoft.Network/virtualNetworks/prod-vnet-core-services"
  }
  "hub-connection-utils-vnet" = {
    hub_name = "WAN-Hub-Melbourne"
    vnet_id  = "/subscriptions/d877ef00-ea85-4a82-816c-b437fb7b1ebc/resourceGroups/rg-core-infra-network/providers/Microsoft.Network/virtualNetworks/prod-vnet-utils-services"
  }
  "hub-connection-ng-stg" = {
    hub_name = "WAN-Hub-Melbourne"
    vnet_id  = "/subscriptions/7b12ad1c-8c8d-45b7-ba98-4a5ebcc14576/resourceGroups/stg-rg-ng-infra-shared-eau/providers/Microsoft.Network/virtualNetworks/stg-vnet-ng-shared-eau"
  }
  "hub-connection-ng-stg-ntrc" = {
    hub_name = "WAN-Hub-Melbourne"
    vnet_id  = "/subscriptions/7b12ad1c-8c8d-45b7-ba98-4a5ebcc14576/resourceGroups/stg-rg-ng-ntrc-shared-eau/providers/Microsoft.Network/virtualNetworks/stg-vnet-ng-ntrc-eau"
  }
  "hub-connection-ng-prd" = {
    hub_name = "WAN-Hub-Melbourne"
    vnet_id  = "/subscriptions/af9d6bfd-3529-48cf-90d9-13e51e420a66/resourceGroups/prd-rg-ng-infra-shared-eau/providers/Microsoft.Network/virtualNetworks/prd-vnet-ng-shared-eau"
  }
  "hub-connection-ng-prd-ntrc" = {
    hub_name = "WAN-Hub-Melbourne"
    vnet_id  = "/subscriptions/af9d6bfd-3529-48cf-90d9-13e51e420a66/resourceGroups/prd-rg-ng-ntrc-shared-eau/providers/Microsoft.Network/virtualNetworks/prd-vnet-ng-ntrc-eau"
  }
  "hub-connection-r2d2-stg" = {
    hub_name = "WAN-Hub-Melbourne"
    vnet_id  = "/subscriptions/bd4719f8-d589-4d72-9d17-d23cc092931f/resourceGroups/stg-rg-r2d2-infra-shared-eau/providers/Microsoft.Network/virtualNetworks/stg-vnet-r2d2-shared-eau"
  }
}

#PLACE HOLDER FOR FUTURE
default_route_table_id = "/subscriptions/d877ef00-ea85-4a82-816c-b437fb7b1ebc/resourceGroups/rg-core-infra-network/providers/Microsoft.Network/virtualHubs/WAN-Hub-Melbourne/hubRouteTables/defaultRouteTable"
none_route_table_id    = "/subscriptions/d877ef00-ea85-4a82-816c-b437fb7b1ebc/resourceGroups/rg-core-infra-network/providers/Microsoft.Network/virtualHubs/WAN-Hub-Melbourne/hubRouteTables/noneRouteTable"
hub_route_tables = {
  # "defaultRouteTable" = {
  #   hub_name = "WAN-Hub-Melbourne"
  #   labels   = ["default"]
  #   route = [
  #     {
  #       name              = "to-internet"
  #       destinations_type = "CIDR"
  #       destinations      = ["0.0.0.0/0"]
  #       next_hop_type     = "ResourceId"
  #       next_hop          = "azure_firewall"
  #     }
  #    ]
  # }
  #Placeholder for Isolated VNET's
  # "rt-vnet-to-internet" = {
  #   hub_name = "WAN-Hub-Melbourne"
  #   labels   = ["isolated"]
  #   route = [
  #     {
  #       name              = "to-internet"
  #       destinations_type = "CIDR"
  #       destinations      = ["0.0.0.0/0"]
  #       next_hop_type     = "ResourceId"
  #       next_hop          = "azure_firewall"
  #     }
  #    ]
  # }
  # "rt-vhub-to-ng-vnet" = {
  #   hub_name = "WAN-Hub-Melbourne"
  #   labels   = ["label1"]
  #   route = {
  #     name              = "example-route"
  #     destinations_type = "CIDR"
  #     destinations      = ["10.4.0.0/20"]
  #     next_hop_type     = "ResourceId"
  #     connection_name   = "hub-connection-ng-dev"
  #   }
  # }
}

core_vnet = {
  name          = "prod-vnet-core-services"
  address_space = ["10.1.0.0/22"]
  subnets = [
    {
      name              = "primary-dc"
      prefixes          = ["10.1.0.0/27"]
      service_endpoints = []
    },
    {
      name              = "secondary-dc"
      prefixes          = ["10.1.1.0/27"]
      service_endpoints = []
    }
    # {
    #   name              = "inbound-privateresolver"
    #   prefixes          = ["10.1.2.224/28"]
    #   service_endpoints = []
    # },
    # {
    #   name              = "outbound-privateresolver"
    #   prefixes          = ["10.1.2.240/28"]
    #   service_endpoints = []
    # }
  ]
}
utils_vnet = {
  name          = "prod-vnet-utils-services"
  address_space = ["10.1.4.0/22"]
  subnets = [
    {
      name              = "subnet-agents"
      prefixes          = ["10.1.4.0/26"]
      service_endpoints = []
    },
    {
      name              = "subnet-sql-monitor"
      prefixes          = ["10.1.5.192/28"]
      service_endpoints = []
    }
  ]
}
#Firewall Variables
firewall_name               = "core-eau-01"
firewall_sku_tier           = "Standard"
firewall_availibility_zones = [1, 2, 3]

#PlaceHolder
#Specify the Application rules for Azure Firewall
# firewall_application_rules = {
#   collection_priority = "200"
#   action = "Allow"
#   rule = [
#      {
#       name             = "microsoft",
#       source_addresses = ["10.1.0.0/22","10.1.4.0/22"],
#       destination_fqdns     = ["*.microsoft.com"],
#      }
#      ]
#      protocols = [
#       {
#         type = "Http"
#         port = "80"
#        },
#        {
#         type = "Https"
#         port = "443"
#        }
#       ]
#   }
# Specify the Network rules for Azure Firewall
firewall_network_rules = {
  collection_priority = 400
  action              = "Allow"
  rule = [
    {
      name                  = "allow-internet-access",
      priority              = "401",
      source_addresses      = ["10.1.0.0/22", "10.1.4.0/22", "10.4.16.0/20", "10.4.244.0/22"],
      destination_ports     = ["80", "443"],
      destination_addresses = ["*"],
      protocols             = ["TCP"],
    },
    {
      name                  = "allow-ntp",
      priority              = "402",
      source_addresses      = ["10.1.0.0/22", "10.1.4.0/22", "10.4.16.0/20", "10.4.244.0/22"],
      destination_ports     = ["123"],
      destination_addresses = ["*"],
      protocols             = ["UDP"],
    },
    {
      name                  = "allow-azure-kms",
      priority              = "403",
      source_addresses      = ["10.1.0.0/22", "10.1.4.0/22", "10.4.16.0/20", "10.4.244.0/22"],
      destination_ports     = ["1688"],
      destination_addresses = ["20.118.99.224", "40.83.235.53", "23.102.135.246"],
      protocols             = ["TCP"],
    }
  ]
}

firewall_nat_rules = {
  collection_priority = 300
  action              = "Dnat"
  rule = [
    {
      name                  = "tbs-iis-nat",
      source_addresses      = ["*"],
      destination_ports     = ["443"],
      destination_addresses = null,
      protocols             = ["TCP"],
      translated_address    = "10.4.2.37",
      translated_port       = "443"
    }
  ]
}

agents_vmss_configs = {
  name                 = "prod-vmss-agents-shared"
  computer_name_prefix = "agent"
  instances            = 4
  image                = {}
  os_disk              = {}
}

agents_vmss_configs_from_image = {
  name                 = "pro-vmss-agents-win-shared"
  computer_name_prefix = "winagent"
  instances            = 2
  image_id             = "/subscriptions/d877ef00-ea85-4a82-816c-b437fb7b1ebc/resourceGroups/rg-core-infra-agents/providers/Microsoft.Compute/images/prd-img-agent-vm-win-20230303.12.48"
  os_disk              = {}
}

#DNSPrivateResolver
dnsresolver_name = "private-dnsresolver"

#Log Analytics
log_analytics_retention                   = 30
internet_ingestion_enabled                = false
internet_query_enabled                    = false
virtual_network_diagnostic_log_categories = ["VMProtectionAlerts"]


shared_vm_config = {
  subnet_name                   = "subnet-sql-monitor"
  virtual_network_name          = "prod-vnet-utils-services"
  vnet_rg                       = "rg-core-infra-network"
  log_analytics_name            = "global-logs-blackstream-workspace-eau"
  log_analytics_rg              = "global-rg-blackstream-infra-shared-eau"
  customized_key_vault_name     = "global-kv-bs-infra-eau"
  resource_group_name           = "global-ng-sql-monitor"
  virtual_machine_size          = "Standard_D2s_v3"
  windows_distribution_name     = "windows2019dc"
  os_disk_storage_account_type  = "Premium_LRS"
  storage_os_disk_caching       = "ReadWrite"
  delete_os_disk_on_termination = true
  nb_data_disk                  = 1
  data_sa_type                  = "Premium_LRS"
  data_disk_size_gb             = 256
  admin_username                = "localadmin"
  admin_password                = null
  # NSG
  security_group_name = "global-nsg-ng-sql-monitor-vm"
}

extra_disks = [
  {
    name = "disk3"
    size = 256
  }
]

vm_configs = {
  "sql-monitor" = {
    count               = 1
    ip_address_type     = "Static"
    static_ip_addresses = ["10.1.5.198"]
  }
}
