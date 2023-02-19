output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "resource_group_name" {
  value = azurerm_kubernetes_cluster.aks.resource_group_name
}

output "node_resource_group" {
  value = azurerm_kubernetes_cluster.aks.node_resource_group
}

output "id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
  sensitive = true
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate
  sensitive   = true
}

output "client_key" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate
  sensitive   = true
}