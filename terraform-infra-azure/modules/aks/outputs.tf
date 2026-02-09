output "id" {
  description = "AKS cluster ID"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "AKS cluster name"
  value       = azurerm_kubernetes_cluster.this.name
}

output "kube_config" {
  description = "Kubernetes config"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Kubelet identity object ID for ACR access"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}
