variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
}

variable "redis_secret" {
  description = "Redis secret name"
  type        = string
}
