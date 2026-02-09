output "resource_group_name" {
  description = "Resource group name"
  value       = module.resource_group.name
}

output "cluster_id" {
  description = "AKS cluster ID"
  value       = module.aks.id
}

output "cluster_name" {
  description = "AKS cluster name"
  value       = module.aks.name
}

output "kube_config" {
  description = "Kubernetes config"
  value       = module.aks.kube_config
  sensitive   = true
}

output "acr_login_server" {
  description = "ACR login server"
  value       = module.acr.login_server
}

output "acr_admin_username" {
  description = "ACR admin username"
  value       = module.acr.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "ACR admin password"
  value       = module.acr.admin_password
  sensitive   = true
}
