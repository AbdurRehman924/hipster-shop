output "id" {
  description = "ACR ID"
  value       = azurerm_container_registry.this.id
}

output "login_server" {
  description = "ACR login server"
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "ACR admin username"
  value       = azurerm_container_registry.this.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "ACR admin password"
  value       = azurerm_container_registry.this.admin_password
  sensitive   = true
}
