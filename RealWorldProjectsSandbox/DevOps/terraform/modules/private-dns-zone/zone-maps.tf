locals {
  private_zone_maps = {
    "cosmosdb_sql" : "privatelink.documents.azure.com"
    "postgresql" : "privatelink.postgres.database.azure.com"
    "signalr" : "privatelink.service.signalr.net"
    "event_grid" : "privatelink.eventgrid.azure.net"
    "service_bus" : "privatelink.servicebus.windows.net" # including service bus, eventhub, relay private link
    "acr" : "privatelink.azurecr.io",
    "keyvault" : "privatelink.vaultcore.azure.net"
    "azure_sql" : "privatelink.database.windows.net"
    "app_config" : "privatelink.azconfig.io"
    "redis_cache" : "privatelink.redis.cache.windows.net"
    "azure_managed_sql_template" : "privatelink.{0}.database.windows.net" # need to provide dns prefix
    "website" : "privatelink.azurewebsites.net"                           # for function app and web service
    "website_scm" : "scm.privatelink.azurewebsites.net"                   # for scm of website
  }
}
