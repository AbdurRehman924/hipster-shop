variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc3"
}

variable "image_tag" {
  description = "Docker image tag for microservices"
  type        = string
  default     = "v0.10.0"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "hipster-shop-google-project"
}
