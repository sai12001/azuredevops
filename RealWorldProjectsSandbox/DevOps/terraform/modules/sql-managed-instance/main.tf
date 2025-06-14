locals {
  tags       = merge(var.resource_group.tags, var.tags)
  sql_mi_nsg = "${var.context.environment}-nsg-${var.context.product}-${var.instance_name}-managed-sql"
  sql_mi_rtb = "${var.context.environment}-rtb-${var.context.product}-${var.instance_name}-managed-sql"

  sql_mi_name = "${var.context.environment}-sqlmi-${var.context.product}-${var.instance_name}"
  sql_mi_config = {
    administrator_login = var.administrator_login
    license_type        = var.license_type
    sku_name            = var.sku_name
    vcores              = var.vcores
    storage_size_in_gb  = var.storage_size_in_gb
  }
  # Diagnostic Settings Config
  log_workspace = {
    name                = "${var.context.environment}-logs-${var.context.product}-workspace-${var.context.location_abbr}"
    resource_group_name = "${var.context.environment}-rg-${var.context.product}-infra-shared-${var.context.location_abbr}"
  }
  sqlmi_diagnostic_log_categories = ["SQLSecurityAuditEvents", "ResourceUsageStats", "DevOpsOperationsAudit"]


}

data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "data_vnet" {
  name                = var.vnet_config.name
  resource_group_name = var.vnet_config.resource_group
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.vnet_config.resource_group
  virtual_network_name = var.vnet_config.name
}

data "azurerm_key_vault" "key_vault" {
  name                = var.key_vault.key_vault_name
  resource_group_name = var.key_vault.resource_group_name
}

data "azurerm_log_analytics_workspace" "law" {
  name                = local.log_workspace.name
  resource_group_name = local.log_workspace.resource_group_name
}

resource "random_password" "sqlmi_sa_password" {
  length  = 24
  special = false
  upper   = true
  lower   = true
}
resource "random_password" "sqlmi_db_user_password" {
  length  = 24
  special = false
  upper   = true
  lower   = true
}

resource "azurerm_mssql_managed_instance" "sqlmi" {
  name                = local.sql_mi_name
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location

  administrator_login          = local.sql_mi_config.administrator_login
  administrator_login_password = random_password.sqlmi_sa_password.result

  collation    = var.collation
  timezone_id  = var.timezone_id
  license_type = local.sql_mi_config.license_type
  sku_name     = local.sql_mi_config.sku_name

  proxy_override = var.proxy_override

  tags = local.tags

  vcores               = local.sql_mi_config.vcores
  storage_size_in_gb   = local.sql_mi_config.storage_size_in_gb
  storage_account_type = var.storage_account_type

  public_data_endpoint_enabled = var.public_data_endpoint_enabled

  subnet_id = data.azurerm_subnet.subnet.id

  lifecycle {
    ignore_changes = [administrator_login, administrator_login_password, subnet_id, sku_name, vcores, storage_size_in_gb]
  }

  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.nsg_assiciation,
    azurerm_subnet_route_table_association.routetable_assiciation,
  ]
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.sql_mi_nsg
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}

resource "azurerm_network_security_rule" "nsg_rules" {
  for_each                    = { for network_security_group_rule in var.network_security_group_rules : network_security_group_rule.name => network_security_group_rule }
  name                        = each.value.name                                                                        //"allow_management_inbound"
  priority                    = each.value.priority                                                                    // 101
  direction                   = each.value.direction                                                                   //"Inbound"
  access                      = each.value.access                                                                      //"Allow"
  protocol                    = each.value.protocol                                                                    //"Tcp"
  source_port_range           = each.value.source_port_range                                                           //"*"
  destination_port_range      = each.value.destination_port_range != null ? each.value.destination_port_range : null   //"*"
  destination_port_ranges     = each.value.destination_port_ranges != null ? each.value.destination_port_ranges : null //["9000", "9003", "1438", "1440", "1452"]
  source_address_prefix       = each.value.source_address_prefix                                                       //"*"
  destination_address_prefix  = each.value.destination_address_prefix                                                  //"*"
  description                 = each.value.description
  resource_group_name         = var.resource_group.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_assiciation" {
  subnet_id                 = data.azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  lifecycle {
    ignore_changes = [subnet_id]
  }
}

resource "azurerm_route_table" "routetable" {
  name                          = local.sql_mi_rtb
  location                      = var.resource_group.location
  resource_group_name           = var.resource_group.name
  disable_bgp_route_propagation = false
  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

resource "azurerm_route" "routes" {
  for_each            = { for route_table_route in var.route_table_routes : route_table_route.name => route_table_route }
  name                = each.value.name
  address_prefix      = each.value.address_prefix
  next_hop_type       = each.value.next_hop_type
  resource_group_name = var.resource_group.name
  route_table_name    = azurerm_route_table.routetable.name
}

resource "azurerm_subnet_route_table_association" "routetable_assiciation" {
  subnet_id      = data.azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.routetable.id
  lifecycle {
    ignore_changes = [subnet_id]
  }
}

resource "azurerm_key_vault_secret" "kv_secret_sqlmi_username" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sqlmi-administrator-username-${local.sql_mi_name}"
  value        = local.sql_mi_config.administrator_login
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_key_vault_secret" "kv_secret_sqlmi_pwd" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sqlmi-administrator-password-${local.sql_mi_name}"
  value        = random_password.sqlmi_sa_password.result
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}


resource "azurerm_key_vault_secret" "kv_secret_sqlmi_db_username" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sqlmi-username-${local.sql_mi_name}"
  value        = var.db_user
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_key_vault_secret" "kv_secret_sqlmi_user_pwd" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sqlmi-password-${local.sql_mi_name}"
  value        = random_password.sqlmi_db_user_password.result
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

resource "azurerm_key_vault_secret" "kv_secret_sqlmi_connection_string" {
  key_vault_id = data.azurerm_key_vault.key_vault.id
  name         = "sqlmi-connectionstring-${local.sql_mi_name}"
  value        = "Server=tcp:${azurerm_mssql_managed_instance.sqlmi.fqdn},1433;Persist Security Info=False;User ID=${var.db_user};Password=${random_password.sqlmi_db_user_password.result};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  lifecycle {
    ignore_changes = [key_vault_id]
  }
}

#----------------------------------------------------------------------------------------------------------
# SQL MI Diagnostic Setting
#----------------------------------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "sqlmi_diags" {
  name                       = format("%s-diags", azurerm_mssql_managed_instance.sqlmi.name)
  target_resource_id         = azurerm_mssql_managed_instance.sqlmi.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.law.id
  dynamic "log" {
    for_each = local.sqlmi_diagnostic_log_categories
    content {
      category = log.value
      retention_policy {
        days    = var.log_analytics_retention
        enabled = true
      }
    }
  }
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }

  }
  depends_on = [
    azurerm_mssql_managed_instance.sqlmi
  ]
}
