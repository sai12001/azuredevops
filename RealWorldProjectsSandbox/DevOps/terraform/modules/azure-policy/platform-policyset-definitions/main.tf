#Data sources
data "azurerm_policy_definition" "req_tags" {
  display_name                  = "Require a tag on resource groups"
}

data "azurerm_policy_definition" "inh_tags" {
  display_name                  = "Inherit a tag from the resource group if missing"
}

# data "azurerm_policy_definition" "nic_pub_ips" {
#   display_name                  = "Network interfaces should not have public IPs"
# }

data "azurerm_policy_definition" "cog_svcs_pub" {
  display_name                  = "Cognitive Services accounts should disable public network access"
}

data "azurerm_policy_definition" "sql_pub" {
  display_name                  = "Public network access on Azure SQL Database should be disabled"
}

data "azurerm_policy_definition" "postgressql_pub" {
  display_name                  = "Public network access should be disabled for PostgreSQL servers"
}

data "azurerm_policy_definition" "mysql_pub" {
  display_name                  = "Public network access should be disabled for MySQL servers"
}

data "azurerm_policy_definition" "mariadb_pub" {
  display_name                  = "Public network access should be disabled for MariaDB servers"
}

data "azurerm_policy_definition" "cosmosdb_pub" {
  display_name                  = "Azure Cosmos DB should disable public network access"
}

data "azurerm_policy_definition" "sqlmi_aad" {
  display_name                  = "Azure SQL Managed Instance should have Azure Active Directory Only Authentication enabled"
}

data "azurerm_policy_definition" "sqlmi_pub" {
  display_name                  = "Azure SQL Managed Instances should disable public network access"
}

data "azurerm_policy_definition" "sql_priv_ep" {
  display_name                  = "Private endpoint connections on Azure SQL Database should be enabled"
}

data "azurerm_policy_definition" "kv_pub" {
  display_name                  = "Azure Key Vault should disable public network access"
}

data "azurerm_policy_definition" "kv_priv" {
  display_name                  = "[Preview]: Azure Key Vaults should use private link"
}

data "azurerm_policy_definition" "stg_pub" {
  display_name                  = "Storage accounts should disable public network access"
}

data "azurerm_policy_definition" "law_pub_ing" {
  display_name                  = "Log Analytics workspaces should block log ingestion and querying from public networks"
}

data "azurerm_policy_definition" "appins_pub_ing" {
  display_name                  = "Application Insights components should block log ingestion and querying from public networks"
}

data "azurerm_policy_definition" "appsvcs_vnet" {
  display_name                  = "App Service apps should be injected into a virtual network"
}

data "azurerm_policy_definition" "appsvcs_priv" {
  display_name                  = "App Service apps should use private link"
}

data "azurerm_policy_definition" "apim_vnet" {
  display_name                  = "API Management services should use a virtual network"
}

data "azurerm_policy_definition" "app_config_pub" {
  display_name                  = "App Configuration should disable public network access"
}

data "azurerm_policy_definition" "acr_loc_adm" {
  display_name                  = "Container registries should have local admin account disabled."
}

data "azurerm_policy_definition" "svc_bus_priv" {
  display_name                  = "Azure Service Bus namespaces should use private link"
}

data "azurerm_policy_definition" "svc_bus_pub" {
  display_name                  = "Service Bus Namespaces should disable public network access"
}

data "azurerm_policy_definition" "apim_pub" {
  display_name                  = "API Management services should disable public network access"
}

#Policy Initiative

resource "azurerm_policy_set_definition" "platform" {
  name                          = "platform-policies"
  policy_type                   = "Custom"
  display_name                  = "platform-policies"
  management_group_id           = var.global_management_group_id
  description                   = "Set of built-in policies that have been curated for the Platform management group."

  policy_definition_reference {
    // Require a tag on resource groups
    policy_definition_id        = data.azurerm_policy_definition.req_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_1}'"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Require a tag on resource groups
    policy_definition_id        = data.azurerm_policy_definition.req_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_2}'"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Require a tag on resource groups
    policy_definition_id        = data.azurerm_policy_definition.req_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_3}'"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Require a tag on resource groups
    policy_definition_id        = data.azurerm_policy_definition.req_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_4}'"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Require a tag on resource groups
    policy_definition_id        = data.azurerm_policy_definition.req_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_5}'"
                }
    }
    VALUE
  }  
  policy_definition_reference {
    // Inherit a tag from the resource group if missing
    policy_definition_id        = data.azurerm_policy_definition.inh_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_1}'"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Inherit a tag from the resource group if missing
    policy_definition_id        = data.azurerm_policy_definition.inh_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_2}'"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Inherit a tag from the resource group if missing
    policy_definition_id        = data.azurerm_policy_definition.inh_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_3}'"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Inherit a tag from the resource group if missing
    policy_definition_id        = data.azurerm_policy_definition.inh_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_4}'"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Inherit a tag from the resource group if missing
    policy_definition_id        = data.azurerm_policy_definition.inh_tags.id
    parameter_values            = <<VALUE
    {
        "tagName": {
                    "value": "'${var.tag_5}'"
                }
    }
    VALUE
  }  
  # policy_definition_reference {
  #   // Network interfaces should not have public IPs
  #   policy_definition_id        = data.azurerm_policy_definition.nic_pub_ips.id
  #   parameter_values            = <<VALUE
  #   {
  #       "effect": {
  #                   "value": "${var.nic_pub_ips_effect}"
  #               }
  #   }
  #   VALUE
  # }
  policy_definition_reference {
    //  Cognitive Services accounts should disable public network access
    policy_definition_id        = data.azurerm_policy_definition.cog_svcs_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.cognitive_services_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Public network access on Azure SQL Database should be disabled
    policy_definition_id        = data.azurerm_policy_definition.sql_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.sql_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Public network access should be disabled for PostgreSQL servers
    policy_definition_id        = data.azurerm_policy_definition.postgressql_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.postgressql_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Public network access should be disabled for MySQL servers
    policy_definition_id        = data.azurerm_policy_definition.mysql_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.mysql_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Public network access should be disabled for MariaDB servers
    policy_definition_id        = data.azurerm_policy_definition.mariadb_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.mariadb_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Azure Cosmos DB should disable public network access
    policy_definition_id        = data.azurerm_policy_definition.cosmosdb_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.cosmosdb_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    //Azure SQL Managed Instance should have Azure Active Directory Only Authentication enabled
    policy_definition_id        = data.azurerm_policy_definition.sqlmi_aad.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.sqlmi_aad_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    //Azure SQL Managed Instances should disable public network access
    policy_definition_id        = data.azurerm_policy_definition.sqlmi_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.sqlmi_pub_effect}"
                }
    }
    VALUE
  }

  policy_definition_reference {
    // Private endpoint connections on Azure SQL Database should be enabled
    policy_definition_id        = data.azurerm_policy_definition.sql_priv_ep.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.sql_private_endpoint_effect}"
                }
    }
    VALUE
  }

  policy_definition_reference {#
    // Azure Key Vault should disable public network access
    policy_definition_id        = data.azurerm_policy_definition.kv_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.key_vault_public_network_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // [Preview]: Azure Key Vaults should use private link
    policy_definition_id        = data.azurerm_policy_definition.kv_priv.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.key_vault_private_link_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Storage accounts should disable public network access
    policy_definition_id        = data.azurerm_policy_definition.stg_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.storage_public_network_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Log Analytics workspaces should block log ingestion and querying from public networks
    policy_definition_id        = data.azurerm_policy_definition.law_pub_ing.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.log_analytics_ingestion_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Application Insights components should block log ingestion and querying from public networks
    policy_definition_id        = data.azurerm_policy_definition.appins_pub_ing.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.app_insights_ingestion_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // App Service apps should be injected into a virtual network
    policy_definition_id        = data.azurerm_policy_definition.appsvcs_vnet.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.app_services_vnet_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // App Service apps should use private link
    policy_definition_id        = data.azurerm_policy_definition.appsvcs_priv.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.app_services_private_link_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // API Management services should use a virtual network
    policy_definition_id        = data.azurerm_policy_definition.apim_vnet.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.apim_vnet_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // App Configuration should disable public network access
    policy_definition_id        = data.azurerm_policy_definition.app_config_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.app_config_public_network_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Container registries should have local admin account disabled.
    policy_definition_id        = data.azurerm_policy_definition.acr_loc_adm.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.acr_loc_adm_effect}"
                }
    }
    VALUE
  } 
  policy_definition_reference {
    // Azure Service Bus namespaces should use private link
    policy_definition_id        = data.azurerm_policy_definition.svc_bus_priv.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.service_bus_private_link_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // Service Bus Namespaces should disable public network access
    policy_definition_id        = data.azurerm_policy_definition.svc_bus_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.service_bus_public_network_effect}"
                }
    }
    VALUE
  }
  policy_definition_reference {
    // API Management services should disable public network access
    policy_definition_id        = data.azurerm_policy_definition.apim_pub.id
    parameter_values            = <<VALUE
    {
        "effect": {
                    "value": "${var.apim_public_network_effect}"
                }
    }
    VALUE
  } 
  lifecycle {
   ignore_changes = [management_group_id]
  }
}