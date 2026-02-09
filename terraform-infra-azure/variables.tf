variable "location" {
  description = "Azure region"
  type        = string
  default     = "Southeast Asia"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "HIPSTER-SHOP"
}

variable "acr_name" {
  description = "Azure Container Registry name (must be globally unique)"
  type        = string
  default     = "hipstershopacr"
}

variable "acr_sku" {
  description = "ACR SKU tier"
  type        = string
  default     = "Basic"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "node_count" {
  description = "Number of nodes"
  type        = number
  default     = 3
}

variable "vm_size" {
  description = "VM size for nodes"
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default = {
    project     = "hipster-shop"
    environment = "learning"
    managed_by  = "terraform"
  }
}
