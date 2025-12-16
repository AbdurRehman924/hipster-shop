output "cluster_id" {
  description = "DOKS cluster ID"
  value       = digitalocean_kubernetes_cluster.hipster_shop.id
}

output "cluster_endpoint" {
  description = "DOKS cluster endpoint"
  value       = digitalocean_kubernetes_cluster.hipster_shop.endpoint
}

output "registry_endpoint" {
  description = "Container registry endpoint"
  value       = digitalocean_container_registry.hipster_shop.endpoint
}

output "frontend_ip" {
  description = "Frontend LoadBalancer IP"
  value       = kubernetes_service.frontend.status.0.load_balancer.0.ingress.0.ip
}

output "redis_host" {
  description = "Redis database host"
  value       = digitalocean_database_cluster.redis.host
  sensitive   = true
}
