output "cluster_id" {
  description = "DOKS cluster ID"
  value       = module.infrastructure.cluster_id
}

output "cluster_endpoint" {
  description = "DOKS cluster endpoint"
  value       = module.infrastructure.cluster_endpoint
}

output "registry_endpoint" {
  description = "Container registry endpoint"
  value       = module.infrastructure.registry_endpoint
}

output "frontend_ip" {
  description = "Frontend LoadBalancer IP"
  value       = module.microservices.frontend_ip
}
