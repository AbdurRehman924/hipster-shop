terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

module "infrastructure" {
  source = "./modules/infrastructure"
  
  do_token     = var.do_token
  region       = var.region
  project_name = var.project_name
}

provider "kubernetes" {
  host  = module.infrastructure.cluster_endpoint
  token = module.infrastructure.cluster_token
  cluster_ca_certificate = base64decode(
    module.infrastructure.cluster_ca_certificate
  )
}

module "microservices" {
  source = "./modules/microservices"
  
  namespace         = var.project_name
  image_tag        = var.image_tag
  redis_host       = module.infrastructure.redis_host
  redis_port       = module.infrastructure.redis_port
  redis_password   = module.infrastructure.redis_password
  
  depends_on = [module.infrastructure]
}
