data "azurerm_resource_group" "rg" {
  name = var.resource_group.name
}

data "azurerm_virtual_network" "vnet" {
  name                = "prod-vnet-core-services"
  resource_group_name = var.resource_group.name
}

data "azurerm_subnet" "inboundsubnet" {
  name                 = "inbound-privateresolver"
  virtual_network_name = "prod-vnet-core-services"
  resource_group_name = var.resource_group.name
}

data "azurerm_subnet" "outboundsubnet" {
  name                 = "outbound-privateresolver"
  virtual_network_name = "prod-vnet-core-services"
  resource_group_name = var.resource_group.name
}

resource "azapi_resource" "dnsresolver" {
  type      = "Microsoft.Network/dnsResolvers@2020-04-01-preview"
  name      = lower("${var.environment}-${var.dnsresolver_name}")
  parent_id = data.azurerm_resource_group.rg.id
  location  = var.resource_group.location

  body = jsonencode({
    properties = {
      virtualNetwork = {
        id = data.azurerm_virtual_network.vnet.id
      }
    }
  })

  response_export_values = ["properties.virtualnetwork.id"]
}

resource "azapi_resource" "inboundendpoint" {
  type      = "Microsoft.Network/dnsResolvers/inboundEndpoints@2020-04-01-preview"
  name      = lower("${var.environment}-${var.dnsresolver_name}-inbound-endpoint")
  parent_id = azapi_resource.dnsresolver.id
  location  = azapi_resource.dnsresolver.location

  body = jsonencode({
    properties = {
      ipConfigurations = [{ subnet = { id = data.azurerm_subnet.inboundsubnet.id } }]
    }
  })

  response_export_values = ["properties.ipconfiguration"]
  depends_on = [
    azapi_resource.dnsresolver
  ]
}

resource "azapi_resource" "outboundendpoint" {
  type      = "Microsoft.Network/dnsResolvers/outboundEndpoints@2020-04-01-preview"
  name      = lower("${var.environment}-${var.dnsresolver_name}-outbound-endpoint")
  parent_id = azapi_resource.dnsresolver.id
  location  = azapi_resource.dnsresolver.location

  body = jsonencode({
    properties = {
      subnet = {
        id = data.azurerm_subnet.outboundsubnet.id
      }
    }
  })

  response_export_values = ["properties.subnet"]
  depends_on = [
    azapi_resource.dnsresolver
  ]
}

resource "azapi_resource" "ruleset" {
  type      = "Microsoft.Network/dnsForwardingRulesets@2020-04-01-preview"
  name      = "blackstream-onprem-resolution"
  parent_id = data.azurerm_resource_group.rg.id
  location  = var.resource_group.location

  body = jsonencode({
    properties = {
      dnsResolverOutboundEndpoints = [{
        id = azapi_resource.outboundendpoint.id
      }]
    }
  })
  depends_on = [
    azapi_resource.dnsresolver
  ]
}

resource "azapi_resource" "resolvervnetlink" {
  type      = "Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2020-04-01-preview"
  name      = "privateresolvervnetlink"
  parent_id = azapi_resource.ruleset.id

  body = jsonencode({
    properties = {
      virtualNetwork = {
        id = azurerm_virtual_network.vnet.id
      }
    }
  })
  depends_on = [
    azapi_resource.dnsresolver
  ]
}


resource "azapi_resource" "forwardingrule" {
  type      = "Microsoft.Network/dnsForwardingRulesets/forwardingRules@2020-04-01-preview"
  name      = "on-prem-blackstream-rule"
  parent_id = azapi_resource.ruleset.id

  body = jsonencode({
    properties = {
      domainName          = "blackstream.com.au."
      forwardingRuleState = "Enabled"
      targetDnsServers = [{
        ipAddress = "10.1.0.4"
        port      = 53
      }]
    }
  })
  depends_on = [
    azapi_resource.dnsresolver
  ]
}
resource "azapi_resource" "forwardingrule1" {
  type      = "Microsoft.Network/dnsForwardingRulesets/forwardingRules@2020-04-01-preview"
  name      = "on-prem-stg-blackstream-rule"
  parent_id = azapi_resource.ruleset.id

  body = jsonencode({
    properties = {
      domainName          = "stg.blackstream.com.au."
      forwardingRuleState = "Enabled"
      targetDnsServers = [{
        ipAddress = "10.1.0.4"
        port      = 53
      }]
    }
  })
  depends_on = [
    azapi_resource.dnsresolver
  ]
}