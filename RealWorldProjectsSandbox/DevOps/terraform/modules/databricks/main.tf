locals {
  tags                        = merge(var.resource_group.tags, var.tags)
  databricks_nsg              = "${var.context.environment}-nsg-${var.context.product}-databricks"
  databricks_autoscale        = var.enable_databricks_autoscale == true ? { dummy_create = true } : {}
  databricks_azure_attributes = var.enable_databricks_azure_attributes == true ? { dummy_create = true } : {}
  databricks_cluster_name     = "${var.context.environment}-cluster-${var.context.product}-databricks"
  storage_account_name        = "databricks"
  storage_account_datalake    = "datalake"
  # Diagnostic Settings
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  databricks_diagnostic_log_categories = ["accounts", "jobs", "notebook", "clusters", "instancePools", "workspace"]
  mas_ai_name                          = "${var.context.environment}-ai-${var.context.product}-mas-databricks-${var.context.location_abbr}"

}

#---------------------------------------
# Existing network and subnets 
#---------------------------------------
data "azurerm_virtual_network" "az_existing_vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_resource_group
}

data "azurerm_subnet" "public_subnet" {
  name                 = var.public_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group
}

data "azurerm_subnet" "private_subnet" {
  name                 = var.private_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.vnet_resource_group
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}
#---------------------------------------
# Network security group
#---------------------------------------
module "nsg_databricks" {
  source              = "../../../../DevOps/terraform/modules/network-security-group"
  resource_group      = var.resource_group
  context             = var.context
  domain              = var.domain_name
  security_group_name = local.databricks_nsg
  custom_rules        = var.network_security_group_rules
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_public" {
  subnet_id                 = data.azurerm_subnet.public_subnet.id
  network_security_group_id = module.nsg_databricks.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc_private" {
  subnet_id                 = data.azurerm_subnet.private_subnet.id
  network_security_group_id = module.nsg_databricks.id
}

#---------------------------------------
# Azure databrick workspace
#---------------------------------------
resource "azurerm_databricks_workspace" "az_databricks_workspace" {
  name                          = var.databricks_workspace_name
  resource_group_name           = var.resource_group.name
  location                      = var.location
  sku                           = var.databricks_sku
  customer_managed_key_enabled  = var.databricks_sku == "premium" ? var.is_customer_managed_key_enabled : null
  public_network_access_enabled = var.is_public_network_access_enabled
  tags                          = local.tags

  custom_parameters {
    machine_learning_workspace_id                        = var.machine_learning_workspace_id
    no_public_ip                                         = var.no_public_ip
    public_ip_name                                       = var.public_ip_name
    virtual_network_id                                   = data.azurerm_virtual_network.az_existing_vnet.id
    public_subnet_name                                   = var.public_subnet_name
    private_subnet_name                                  = var.private_subnet_name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.nsg_assoc_public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.nsg_assoc_private.id
    storage_account_name                                 = lower(substr(replace("${var.context.environment}sta${var.context.product}${local.storage_account_name}${var.context.location_abbr}${random_string.storage_suffix.result}", "-", ""), 0, 24))
    storage_account_sku_name                             = var.storage_account_sku_name
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.nsg_assoc_public,
    azurerm_subnet_network_security_group_association.nsg_assoc_private,
  ]
}

#---------------------------------------
# Storage Account Random String
#---------------------------------------
resource "random_string" "storage_suffix" {
  length  = 24
  special = false
  lower   = true
  upper   = false
  number  = false
}

#---------------------------------------
# Databricks cluster
#---------------------------------------
resource "databricks_cluster" "cluster" {
  count                   = var.enable_databricks_cluster == true ? 1 : 0
  cluster_name            = local.databricks_cluster_name
  spark_version           = var.databricks_spark_version
  node_type_id            = var.databricks_node_type_id
  autotermination_minutes = var.databricks_autotermination_minutes
  driver_node_type_id     = var.databricks_driver_node_type_id

  dynamic "autoscale" {
    for_each = local.databricks_autoscale
    content {
      min_workers = var.databricks_min_workers
      max_workers = var.databricks_max_workers
    }
  }

  dynamic "azure_attributes" {
    for_each = local.databricks_azure_attributes
    content {
      availability       = var.databricks_availability
      first_on_demand    = var.databricks_first_on_demand
      spot_bid_max_price = var.databricks_spot_bid_max_price
    }
  }

  num_workers    = var.enable_databricks_autoscale == true ? null : var.databricks_num_workers
  spark_conf     = zipmap(var.databricks_spark_conf_keys, var.databricks_spark_confs_vals)
  custom_tags    = zipmap(var.databricks_tag_keys, var.databricks_tag_vals)
  spark_env_vars = zipmap(var.databricks_spark_env_keys, var.databricks_spark_env_vals)
  depends_on = [
    azurerm_databricks_workspace.az_databricks_workspace
  ]
}

#---------------------------------------
# Maven Library
#---------------------------------------

resource "databricks_library" "maven" {
  cluster_id = databricks_cluster.cluster[0].id
  maven {
    coordinates = var.maven_library
  }
}

#---------------------------------------
# Phyton Libraries
#---------------------------------------

resource "databricks_library" "pypi_pyarrow" {
  cluster_id = databricks_cluster.cluster[0].id
  pypi {
    package = var.python_library_pyarrow
  }
}

resource "databricks_library" "pypi_opencensus" {
  cluster_id = databricks_cluster.cluster[0].id
  pypi {
    package = var.python_library_opencensus
  }
}

resource "databricks_library" "pypi_opencensus_ext_azure" {
  cluster_id = databricks_cluster.cluster[0].id
  pypi {
    package = var.python_library_opencensus_ext_azure
  }
}

resource "databricks_library" "pypi_protobuf" {
  cluster_id = databricks_cluster.cluster[0].id
  pypi {
    package = var.python_library_protobuf
  }
  depends_on = [
    databricks_library.pypi_opencensus, databricks_library.pypi_opencensus_ext_azure
  ]
}




#---------------------------------------
# Storage Account Datalake
#---------------------------------------
module "storage_account" {
  source         = "../../../../DevOps/terraform/modules/storage-account"
  account_name   = lower(substr(replace("${var.context.environment}sta${var.context.product}${local.storage_account_datalake}${var.context.location_abbr}${random_string.storage_suffix.result}", "-", ""), 0, 24))
  resource_group = var.resource_group
  domain         = var.domain_name
  context        = var.context
  is_hns_enabled = true
  containers     = var.containers
  blobs          = var.blobs
  depends_on = [
    azurerm_databricks_workspace.az_databricks_workspace
  ]
}
#----------------------------------------------------------------------------------------------------------
# Databricks Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "databricks_diags" {
  name                       = format("%s-diags", azurerm_databricks_workspace.az_databricks_workspace.name)
  target_resource_id         = azurerm_databricks_workspace.az_databricks_workspace.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  #Placeholder to choose log categories
  dynamic "log" {
    for_each = local.databricks_diagnostic_log_categories
    content {
      category = log.value
      retention_policy {
        days    = var.log_analytics_retention
        enabled = true
      }
    }
  }
  depends_on = [
    azurerm_databricks_workspace.az_databricks_workspace
  ]
}

#---------------------------------------
# Azure Key Vault data source PAT token
#---
data "azurerm_key_vault" "key_vault" {
  name                = "${var.context.environment}-kv-${var.context.product}-${var.context.domain}-${var.context.location_abbr}"
  resource_group_name = "${var.context.environment}-rg-${var.context.product}-${var.context.domain}-shared-${var.context.location_abbr}"
}


data "azurerm_key_vault_secret" "pat_user_id" {
  name         = "ext-databricks-data-user-pat-id"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "pat_user_token" {
  name         = "ext-databricks-data-user-pat-token"
  key_vault_id = data.azurerm_key_vault.key_vault.id
}

#---------------------------------------
# Repo
#---------------------------------------

resource "databricks_git_credential" "ado" {
  git_username          = data.azurerm_key_vault_secret.pat_user_id.value
  git_provider          = "azureDevOpsServices"
  personal_access_token = data.azurerm_key_vault_secret.pat_user_token.value
  force                 = true
}

resource "databricks_repo" "ConsoleDatabricks" {
  url = "https://BlackStream@dev.azure.com/BlackStream/NextGen/_git/Console.ActivityStatement.Databricks"
  #path = "/Repos/Console.ActivityStatement.Databricks"
  branch = var.branch
}

#---------------------------------------
# Task TF - TEST ONE OFF STRUCTURE
#---------------------------------------

resource "databricks_job" "landing_one_off" {
  for_each            = { for job in var.task_configuration_one_off : job.name => job }
  name                = each.value.name
  max_concurrent_runs = each.value.max_concurrent_runs



  git_source {
    url      = each.value.url
    provider = "azureDevOpsServices"
    branch   = var.branch
  }

  task {
    task_key = each.value.task_key

    notebook_task {
      notebook_path = each.value.notebook_path # workspace notebook not required /
    }
    existing_cluster_id = databricks_cluster.cluster[0].id

  }
  depends_on = [
    databricks_git_credential.ado
  ]

}

#---------------------------------------
# Task workflow
#---------------------------------------

resource "databricks_job" "client_ingestion_aut" {
  for_each            = { for job in var.task_configuration : job.name => job }
  name                = each.value.name
  max_concurrent_runs = each.value.max_concurrent_runs

  # job schedule
  schedule {
    quartz_cron_expression = each.value.quartz_cron_expression
    timezone_id            = "UTC"
  }

  git_source {
    url      = each.value.url
    provider = "azureDevOpsServices"
    branch   = var.branch
  }

  task {
    task_key = each.value.task_key

    notebook_task {
      notebook_path = each.value.notebook_path
    }
    existing_cluster_id = databricks_cluster.cluster[0].id
  }

  depends_on = [
    databricks_git_credential.ado, databricks_cluster.cluster
  ]

}

# databricks application insights
module "application_insights_databricks" {
  source                    = "../../../../DevOps/terraform/modules/application-insights"
  application_insights_name = local.mas_ai_name
  resource_group            = var.resource_group
  log_workspace             = data.azurerm_log_analytics_workspace.law
  tags                      = local.tags
  domain                    = var.domain_name
  environment               = var.context.environment
}