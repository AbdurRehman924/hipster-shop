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

provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.hipster_shop.endpoint
  token = digitalocean_kubernetes_cluster.hipster_shop.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.hipster_shop.kube_config[0].cluster_ca_certificate
  )
}

# DOKS Cluster
resource "digitalocean_kubernetes_cluster" "hipster_shop" {
  name    = "hipster-shop"
  region  = var.region
  version = "1.28.2-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-4gb"
    node_count = 3
  }
}

# Container Registry
resource "digitalocean_container_registry" "hipster_shop" {
  name                   = "hipster-shop"
  subscription_tier_slug = "basic"
}

# Redis for Cart Service
resource "digitalocean_database_cluster" "redis" {
  name       = "hipster-shop-redis"
  engine     = "redis"
  version    = "7"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1
}
