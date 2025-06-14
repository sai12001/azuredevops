output "client_key" {
  sensitive = true
  value = azurerm_kubernetes_cluster.main.kube_config[0].client_key
}

output "client_certificate" {
  sensitive = true
  value = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
}

output "host" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].host
}

output "username" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].username
}

output "password" {
  sensitive = true
  value = azurerm_kubernetes_cluster.main.kube_config[0].password
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.main.node_resource_group
}

output "location" {
  value = azurerm_kubernetes_cluster.main.location
}

output "aks_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "kube_config_raw" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
}

output "kube_admin_config_raw" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.main.kube_admin_config_raw
}

output "system_assigned_identity" {
  value = azurerm_kubernetes_cluster.main.identity
}

output "kubelet_identity" {
  value = azurerm_kubernetes_cluster.main.kubelet_identity
}

output "admin_client_key" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.client_key : ""
  sensitive = true
}

output "admin_client_certificate" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.client_certificate : ""
  sensitive = true
}

output "admin_cluster_ca_certificate" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.cluster_ca_certificate : ""
  sensitive = true
}

output "admin_host" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.host : ""
}

output "admin_username" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.username : ""
}

output "admin_password" {
  value = length(azurerm_kubernetes_cluster.main.kube_admin_config) > 0 ? azurerm_kubernetes_cluster.main.kube_admin_config.0.password : ""
  sensitive = true
}

output "public_ssh_key" {
  value = tls_private_key.ssh.public_key_openssh
  sensitive = true
}

output "private_ssh_key" {
  value = tls_private_key.ssh.private_key_pem
  sensitive = true
}
