output "cluster_id" {
  description = "DOKS cluster ID"
  value       = digitalocean_kubernetes_cluster.hipster_shop.id
}

output "cluster_endpoint" {
  description = "DOKS cluster endpoint"
  value       = digitalocean_kubernetes_cluster.hipster_shop.endpoint
}

output "cluster_token" {
  description = "DOKS cluster token"
  value       = digitalocean_kubernetes_cluster.hipster_shop.kube_config[0].token
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "DOKS cluster CA certificate"
  value       = digitalocean_kubernetes_cluster.hipster_shop.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "registry_endpoint" {
  description = "Container registry endpoint"
  value       = digitalocean_container_registry.hipster_shop.endpoint
}
