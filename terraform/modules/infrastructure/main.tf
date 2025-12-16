terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# DigitalOcean Project
data "digitalocean_project" "hipster_shop" {
  name = var.project_name
}

# DOKS Cluster
resource "digitalocean_kubernetes_cluster" "hipster_shop" {
  name    = "hipster-shop"
  region  = var.region
  version = "1.34.1-do.1"

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

# Assign resources to project (container registry doesn't support urn)
resource "digitalocean_project_resources" "hipster_shop" {
  project = data.digitalocean_project.hipster_shop.id
  resources = [
    digitalocean_kubernetes_cluster.hipster_shop.urn,
    digitalocean_database_cluster.redis.urn
  ]
}
