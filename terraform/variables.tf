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
  default     = "v0.10.4"
}
