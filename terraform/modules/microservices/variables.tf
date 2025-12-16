variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag for microservices"
  type        = string
}

variable "redis_host" {
  description = "Redis host"
  type        = string
}

variable "redis_port" {
  description = "Redis port"
  type        = string
}

variable "redis_password" {
  description = "Redis password"
  type        = string
  sensitive   = true
}
