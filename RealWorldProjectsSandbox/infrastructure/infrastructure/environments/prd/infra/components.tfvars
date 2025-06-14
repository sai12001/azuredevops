domain_name = "infra"
team_name   = "cloudops"

# ACR Config
acr_config = {
  sku           = "Standard"
  admin_enabled = true
}

#Redis Cache Parameters
redis_config = {
  capacity = 2
  family   = "c"
  sku_name = "Standard"
}

# SignalR Parameters
signalr_config = {

  allowed_origins           = ["*", "https://blackstream.com.au"]
  connectivity_logs_enabled = true
  messaging_logs_enabled    = true
  live_trace_enabled        = true
  service_mode              = "Serverless"
  sku = {
    "capacity" : 1,
    "name" : "Standard_S1"
  }

  category_pattern    = ["*"]
  event_pattern       = ["*"]
  hub_pattern         = ["*"]
  url_template        = "http://localhost:7071/api/test"
  enable_action_group = true
  dashboard_name      = "SignalR Dashboard"
}

# SignalR Metric Alert Parameters
signalr_metric_alert = {
  ConnectionQuotaAlert = {
    description        = "The percentage of connection connected relative to connection quota"
    metric_name        = "ConnectionQuotaUtilization"
    aggregation        = "Maximum"
    operator           = "GreaterThan"
    threshold          = 75
    dimension_name     = "No Dimensions"
    dimension_operator = ""
    dimension_values   = [""]
  }

  ServerLoadAlert = {
    description        = "SignalR server load"
    metric_name        = "ServerLoad"
    aggregation        = "Maximum"
    operator           = "GreaterThan"
    threshold          = 75
    dimension_name     = "No Dimensions"
    dimension_operator = ""
    dimension_values   = [""]
  }

  SystemErrorAlert = {
    description        = "The percentage of system errors"
    metric_name        = "SystemErrors"
    aggregation        = "Maximum"
    operator           = "GreaterThan"
    threshold          = 70
    dimension_name     = "No Dimensions"
    dimension_operator = ""
    dimension_values   = [""]
  }
}

# Apim configuraiton
apim_config = {
  publisher_name  = "Blackstream"
  publisher_email = "cloud@blackstream.com.au"
  sku_name        = "Premium_1"
  base_dns        = "blackstream.com.au"

  dashboard_name      = "API Management Dashboard"
  enable_action_group = true
  ag_short_name       = "ag-email-sms"

  enable_email_receiver = true
  email_name            = "ag-apim-email"
  email_address         = "test@blackstream.com.au"

  enable_sms_receiver = true
  sms_name            = "ag-apim-sms"
  sms_phone_number    = 777678678

  enable_voice_receiver = false
  voice_name            = "ag-apim-voice"
  voice_phone_number    = 777678678

}
apim_certificates = {
  chain = {
    encoded_certificate = "apim/certificates/chain.cer"
    store_name          = "CertificateAuthority"
  }
}

# API Management Metric Alert Parameters
apim_metric_alert = {
  CapacityOverloaded = {
    description        = "Reflects the gateway capacity at the time of reporting"
    metric_name        = "Capacity"
    aggregation        = "Average"
    operator           = "GreaterThan"
    threshold          = 95
    dimension_name     = "Location"
    dimension_operator = "Include"
    dimension_values   = ["Australia East"]
  }

  ServerErrors = {
    description        = "API traffic going through your API Management services"
    metric_name        = "Requests"
    aggregation        = "Total"
    operator           = "GreaterThan"
    threshold          = 100
    dimension_name     = "GatewayResponseCodeCategory"
    dimension_operator = "Include"
    dimension_values   = ["5xx"]
  }

  ServicesErrors = {
    description        = "API traffic going through your API Management services"
    metric_name        = "Requests"
    aggregation        = "Total"
    operator           = "GreaterThan"
    threshold          = 2000
    dimension_name     = "BackendResponseCodeCategory"
    dimension_operator = "Include"
    dimension_values   = ["4xx"]
  }


  RequestDurations = {
    description        = "Overall Duration of Gateway Requests"
    metric_name        = "Duration"
    aggregation        = "Average"
    operator           = "GreaterThan"
    threshold          = 20000
    dimension_name     = "Location"
    dimension_operator = "Include"
    dimension_values   = ["Australia East"]
  }

  GatewayFailures = {
    description        = "Failed Gateway Requests"
    metric_name        = "FailedRequests"
    aggregation        = "Total"
    operator           = "GreaterThan"
    threshold          = 500
    dimension_name     = "Location"
    dimension_operator = "Include"
    dimension_values   = ["Australia East"]
  }
}

# Action group Module Variables
action_groups = {
  sre = {
    enable_email_receiver = true
    ag_short_name         = "sre-action"

    email = {
      email_name    = "Cloud"
      email_address = "cloud@blackstream.com.au"
    }
  }
}

# servicebus config
servicebus_config = {
  sku = "Standard"
}

sql_mi = {
  instance_name                = "tbs"
  resource_group               = "prd-rg-ng-tbs-sql"
  administrator_login          = "tbs-sa"
  db_user                      = "tbsuser"
  collation                    = "Latin1_General_CI_AS"
  vcores                       = 4
  storage_account_type         = "GRS"
  storage_size_in_gb           = 1024
  proxy_override               = "Redirect"
  timezone_id                  = "AUS Eastern Standard Time"
  license_type                 = "BasePrice"
  sku_name                     = "GP_Gen5"
  subnet_name                  = "subnet-managed-sql"
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
      priority                   = 1200
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
      priority                   = 1300
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

databricks = {
  databricks_workspace_name = "prd-ng-databricks-wspace"
  databricks_sku            = "premium"
  storage_account_sku_name  = "Standard_GRS"
  resource_group            = "prd-rg-ng-databricks-eau"
  private_subnet_name       = "subnet-databricks-containers"
  public_subnet_name        = "subnet-databricks-host"
  driver_node_type_id       = "Standard_DS3_v2"
  spark_version             = "10.4.x-scala2.12"
  vnet_name                 = "prd-vnet-ng-shared-eau"
  vnet_resource_group       = "prd-rg-ng-infra-shared-eau"
  branch                    = "release/release-latest"
  domain_name               = "infra"
  network_security_group_rules = [
    {
      name                       = "AzureDatabricks"
      priority                   = 800
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "10.4.39.0/25"
      destination_address_prefix = "AzureDatabricks"
      description                = "Allow AzureDatabricks outbound traffic over https"
    },
    {
      name                       = "SQL"
      priority                   = 810
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "3306"
      source_address_prefix      = "10.4.39.0/25"
      destination_address_prefix = "SQL"
      description                = "Allow SQL outbound traffic"
    },
    {
      name                       = "Storage"
      priority                   = 820
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "10.4.39.0/25"
      destination_address_prefix = "Storage"
      description                = "Allow Storage outbound traffic"
    },
    {
      name                       = "EventHub"
      priority                   = 830
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "9093"
      source_address_prefix      = "10.4.39.0/25"
      destination_address_prefix = "EventHub"
      description                = "Allow EventHub outbound traffic"
    },
    {
      name                       = "NFS 111"
      priority                   = 840
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "111"
      source_address_prefix      = "10.4.39.0/25"
      destination_address_prefix = "*"
      description                = "Allow NFS port 111 outbound traffic"
    },
    {
      name                       = "NFS 2049"
      priority                   = 850
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "2049"
      source_address_prefix      = "10.4.39.0/25"
      destination_address_prefix = "*"
      description                = "Allow NFS port 2049 outbound traffic"
    }
  ]
  containers = [
    {
      name        = "consumption"
      access_type = "private"
    },
    {
      name        = "landing"
      access_type = "private"
    },
    {
      name        = "transformation"
      access_type = "private"
    },
    {
      name        = "ingestion"
      access_type = "private"
    },
    {
      name        = "config"
      access_type = "private"
    }
  ]
  blobs = {
    blob_1 = {
      name           = "client/transformation_client_empty_file.txt"
      container_name = "transformation"
      type           = "Block"
    },
    blob_2 = {
      name           = "client_df/transformation_client_df_empty_file.txt"
      container_name = "transformation"
      type           = "Block"
    },
    blob_3 = {
      name           = "bethistory/transformation_bethistory_empty_file.txt"
      container_name = "transformation"
      type           = "Block"
    },
    blob_4 = {
      name           = "actransaction/transformation_actransaction_empty_file.txt"
      container_name = "transformation"
      type           = "Block"
    },
    blob_5 = {
      name           = "bethistoryleg/transformation_bethistoryleg_empty_file.txt"
      container_name = "transformation"
      type           = "Block"
    },
    blob_6 = {
      name           = "client/landing_client_empty_file.txt"
      container_name = "landing"
      type           = "Block"
    },
    blob_7 = {
      name           = "bethistory/landing_bethistory_empty_file.txt"
      container_name = "landing"
      type           = "Block"
    },
    blob_8 = {
      name           = "actransaction/landing_actransaction_empty_file.txt"
      container_name = "landing"
      type           = "Block"
    },
    blob_9 = {
      name           = "client/consumption_client_empty_file.txt"
      container_name = "consumption"
      type           = "Block"
    },
    blob_10 = {
      name           = "bethistory/consumption_bethistory_empty_file.txt"
      container_name = "consumption"
      type           = "Block"
    },
    blob_11 = {
      name           = "bethistoryleg/consumption_bethistoryleg_empty_file.txt"
      container_name = "consumption"
      type           = "Block"
    },
    blob_12 = {
      name           = "actransaction/consumption_actransaction_empty_file.txt"
      container_name = "consumption"
      type           = "Block"
    },
    blob_13 = {
      name           = "bethistoryleg/consumption_actransaction_empty_file.txt"
      container_name = "consumption"
      type           = "Block"
    },
    blob_14 = {
      name           = "client/ingestion_client_empty_file.txt"
      container_name = "ingestion"
      type           = "Block"
    }
    blob_15 = {
      name           = "bethistory/ingestion_bethistory_empty_file.txt"
      container_name = "ingestion"
      type           = "Block"
    }
    blob_16 = {
      name           = "actransaction/ingestion_actransaction_empty_file.txt"
      container_name = "ingestion"
      type           = "Block"
    }
    blob_17 = {
      name           = "logs/consumption/actransaction/config_actransaction_empty_file.txt"
      container_name = "config"
      type           = "Block"
    }
    blob_18 = {
      name           = "logs/consumption/bethistory/config_bethistory_empty_file.txt"
      container_name = "config"
      type           = "Block"
    }
    blob_19 = {
      name           = "logs/consumption/bethistory_leg/config_bethistory_leg_empty_file.txt"
      container_name = "config"
      type           = "Block"
    }
    blob_20 = {
      name           = "logs/consumption/clients/config_clients_empty_file.txt"
      container_name = "config"
      type           = "Block"
    }
    blob_21 = {
      name           = "logs/transformation/actransaction/config_actransaction_empty_file.txt"
      container_name = "config"
      type           = "Block"
    }
    blob_22 = {
      name           = "logs/transformation/bethistory/config_bethistory_empty_file.txt"
      container_name = "config"
      type           = "Block"
    }
    blob_23 = {
      name           = "logs/transformation/client/config_client_empty_file.txt"
      container_name = "config"
      type           = "Block"
    }
  },
  task_configuration = [
    {
      name                   = "actransaction_ingestion"
      max_concurrent_runs    = 1
      quartz_cron_expression = "3 1/5 * * * ?"
      timezone_id            = "UTC"
      url                    = "https://BlackStream@dev.azure.com/BlackStream/NextGen/_git/Console.ActivityStatement.Databricks"
      task_key               = "actransaction_ingestion"
      notebook_path          = "src/bet_deluxe_dev/ingestion/actransaction/to_ingestion_actransaction"
    },
    {
      name                   = "bethistory_ingestion"
      max_concurrent_runs    = 1
      quartz_cron_expression = "3 1/5 * * * ?"
      timezone_id            = "UTC"
      url                    = "https://BlackStream@dev.azure.com/BlackStream/NextGen/_git/Console.ActivityStatement.Databricks"
      task_key               = "ingestion_bethistory"
      notebook_path          = "src/bet_deluxe_dev/ingestion/bethistory/to_ingestion_bethistory"
    },
    {
      name                   = "client_ingestion"
      max_concurrent_runs    = 1
      quartz_cron_expression = "3 1/5 * * * ?"
      timezone_id            = "UTC"
      url                    = "https://BlackStream@dev.azure.com/BlackStream/NextGen/_git/Console.ActivityStatement.Databricks"
      task_key               = "client_ingestion"
      notebook_path          = "src/bet_deluxe_dev/ingestion/client/to_ingestion_client"
    },
    {
      name                   = "monthly_client_id_upload"
      max_concurrent_runs    = 1
      quartz_cron_expression = "7 0 4 1 * ?"
      timezone_id            = "UTC"
      url                    = "https://BlackStream@dev.azure.com/BlackStream/NextGen/_git/Console.ActivityStatement.Databricks"
      task_key               = "monthly_client_id_upload"
      notebook_path          = "src/upload_clientid/write_client_ids"
    }
  ]
  task_configuration_one_off = [
    {
      name                   = "bethistory_landing"
      max_concurrent_runs    = 1
      timezone_id            = "UTC"
      url                    = "https://BlackStream@dev.azure.com/BlackStream/NextGen/_git/Console.ActivityStatement.Databricks"
      task_key               = "bethistory_landing"
      notebook_path          = "src/bet_deluxe_dev/landing/bethistory/to_landing_bethistory"
    },
    {
      name                   = "actransaction_landing"
      max_concurrent_runs    = 1
      timezone_id            = "UTC"
      url                    = "https://BlackStream@dev.azure.com/BlackStream/NextGen/_git/Console.ActivityStatement.Databricks"
      task_key               = "actransaction_landing"
      notebook_path          = "src/bet_deluxe_dev/landing/actransaction/to_landing_actransaction"
    }    
  ]
}

# powerbi embedded
powerbi = {
  sku_name       = "A1"
  resource_group = "prd-rg-ng-powerbi-eau"
  administrators = ["Preston@blackstream.com.au", "jay@blackstream.com.au", "luiz@blackstream.com.au"]
}

# network security groups
nsg_configs = {
}


#Diagnostic Settings
#Production LogAnalytics Workspace
log_analytics_name         = "prd-logs-ng-workspace-eau"
log_analytics_rg_name      = "prd-rg-ng-infra-shared-eau"
log_analytics_workspace_id = "/subscriptions/af9d6bfd-3529-48cf-90d9-13e51e420a66/resourcegroups/prd-rg-ng-infra-shared-eau/providers/microsoft.operationalinsights/workspaces/prd-logs-ng-workspace-eau"
log_analytics_retention    = 30


static_sta_brands = ["surge"]