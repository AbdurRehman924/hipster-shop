output "frontend_ip" {
  description = "Frontend LoadBalancer IP"
  value       = module.frontend.load_balancer_ip
}
