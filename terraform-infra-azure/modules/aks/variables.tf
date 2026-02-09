variable "name" {
  description = "AKS cluster name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.34"
}

variable "node_count" {
  description = "Number of nodes in default pool"
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
  default     = {}
}
