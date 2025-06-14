domain_name = "infra"
team_name   = "cloudops"

# Private Links Configuration
privatelink_dns_zones = ["cosmosdb_sql", "service_bus", "redis_cache", "signalr", "keyvault", "azure_sql"]

# shared vnet and subnets
vnet = {
  name          = "prd-vnet-ng-shared-eau"
  address_space = ["10.4.32.0/20"]
  subnets = [
    {
      name              = "AzureFirewallSubnet"
      prefixes          = ["10.4.32.0/24"]
      service_endpoints = []
    },
    {
      name              = "subnet-privatelinks"
      prefixes          = ["10.4.33.0/24"]
      service_endpoints = ["Microsoft.AzureCosmosDB", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Web", "Microsoft.KeyVault", "Microsoft.ContainerRegistry"]
    },
    {
      name              = "subnet-apim"
      prefixes          = ["10.4.34.0/27"]
      service_endpoints = ["Microsoft.Web", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql"]
    },
    {
      name     = "subnet-tbs-vms"
      prefixes = ["10.4.34.32/27"]
      service_endpoints = [
        "Microsoft.EventHub",
        "Microsoft.KeyVault",
        "Microsoft.ServiceBus",
        "Microsoft.Sql",
        "Microsoft.Web"
      ]
    },
    {
      name     = "subnet-psql"
      prefixes = ["10.4.38.0/26"]
      delegation = {
        name = "Microsoft.DBforPostgreSQL.flexibleServers"
        service_delegation = {
          name    = "Microsoft.DBforPostgreSQL/flexibleServers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name     = "subnet-managed-sql"
      prefixes = ["10.4.38.64/26"]
      delegation = {
        name = "Microsoft.Sql.managedInstances"
        service_delegation = {
          name = "Microsoft.Sql/managedInstances"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action",
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
          ]
        }
      }
      service_endpoints = []
    },
    {
      name     = "subnet-databricks-host"
      prefixes = ["10.4.39.0/26"]
      delegation = {
        name = "Microsoft.Databricks.workspaces"
        service_delegation = {
          name = "Microsoft.Databricks/workspaces"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action",
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
          ]
        }
      }
      service_endpoints = [
        "Microsoft.EventHub",
        "Microsoft.Storage",
        "Microsoft.KeyVault",
      ]
    },
    {
      name     = "subnet-databricks-containers"
      prefixes = ["10.4.39.64/26"]
      delegation = {
        name = "Microsoft.Databricks.workspaces"
        service_delegation = {
          name = "Microsoft.Databricks/workspaces"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action",
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
          ]
        }
      }
      service_endpoints = [
        "Microsoft.EventHub",
        "Microsoft.Storage",
        "Microsoft.KeyVault",
      ]
    }
  ]
}

enable_ntrc = true
vnet_ntrc = {
  name          = "prd-vnet-ng-ntrc-eau"
  address_space = ["10.4.248.0/22"]
  subnets = [
    {
      name     = "subnet-db"
      prefixes = ["10.4.248.0/26"]
      delegation = {
        name = "Microsoft.Sql.managedInstances"
        service_delegation = {
          name = "Microsoft.Sql/managedInstances"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action",
            "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
            "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
          ]
        }
      }
      service_endpoints = []
    }
  ]
}

ntrc_sql_mi = {
  instance_name                = "ntrc"
  administrator_login          = "ntrc-sa"
  db_user                      = "ntrcuser"
  collation                    = "Latin1_General_CI_AS"
  vcores                       = 4
  storage_account_type         = "GRS"
  storage_size_in_gb           = 1024
  proxy_override               = "Redirect"
  timezone_id                  = "AUS Eastern Standard Time"
  license_type                 = "BasePrice"
  sku_name                     = "GP_Gen5"
  subnet_name                  = "subnet-db"
  public_data_endpoint_enabled = false
  network_security_group_rules = [
    {
      name                       = "allow_tds_inbound"
      priority                   = 1000
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow access to data"
    },
    {
      name                       = "allow_redirect_inbound"
      priority                   = 1100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "11000-11999"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow inbound redirect traffic to Managed Instance inside the virtual network"
    },
    {
      name                       = "allow_geodr_inbound"
      priority                   = 1200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5022"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Allow inbound geodr traffic inside the virtual network"
    },
    {
      name                       = "deny_all_inbound"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all other inbound traffic"
    },
    {
      name                       = "allow_linkedserver_outbound"
      priority                   = 1000
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "1433"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow outbound linkedserver traffic inside the virtual network"
    },
    {
      name                       = "allow_redirect_outbound"
      priority                   = 1100
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "11000-11999"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow outbound redirect traffic to Managed Instance inside the virtual network"
    },
    {
      name                       = "allow_geodr_outbound"
      priority                   = 1200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5022"
      source_address_prefix      = "*"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow outbound geodr traffic inside the virtual network"
    },
    {
      name                       = "deny_all_outbound"
      priority                   = 4096
      direction                  = "Outbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Deny all other outbound traffic"
    }
  ]
}

#Diagnostic Settings
#Production LogAnalytics Workspace
log_analytics_name                        = "prd-logs-ng-workspace-eau"
log_analytics_rg_name                     = "prd-rg-ng-infra-shared-eau"
log_analytics_workspace_id                = "/subscriptions/af9d6bfd-3529-48cf-90d9-13e51e420a66/resourcegroups/prd-rg-ng-infra-shared-eau/providers/microsoft.operationalinsights/workspaces/prd-logs-ng-workspace-eau"
log_analytics_retention                   =  30