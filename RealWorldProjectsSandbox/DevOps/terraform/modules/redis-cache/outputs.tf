output "instance" {
  description = "The resource group information needed for downstream"
  value = {
    name = azurerm_redis_cache.redis_cache.name
  }
}
