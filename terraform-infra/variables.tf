variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "sgp1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "hipster-shop-google-project"
}
