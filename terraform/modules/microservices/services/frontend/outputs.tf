output "load_balancer_ip" {
  description = "Frontend LoadBalancer IP"
  value       = kubernetes_service.frontend.status.0.load_balancer.0.ingress.0.ip
}
