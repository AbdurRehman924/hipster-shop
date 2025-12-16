terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

# Namespace
resource "kubernetes_namespace" "hipster_shop" {
  metadata {
    name = var.namespace
  }
}

# Redis Secret
resource "kubernetes_secret" "redis" {
  metadata {
    name      = "redis-secret"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  data = {
    host     = var.redis_host
    port     = var.redis_port
    password = var.redis_password
  }
}

module "frontend" {
  source = "./services/frontend"
  
  namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag = var.image_tag
}

module "cartservice" {
  source = "./services/cartservice"
  
  namespace   = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag   = var.image_tag
  redis_secret = kubernetes_secret.redis.metadata[0].name
}

module "productcatalogservice" {
  source = "./services/productcatalogservice"
  
  namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag = var.image_tag
}

module "currencyservice" {
  source = "./services/currencyservice"
  
  namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag = var.image_tag
}

module "paymentservice" {
  source = "./services/paymentservice"
  
  namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag = var.image_tag
}

module "shippingservice" {
  source = "./services/shippingservice"
  
  namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag = var.image_tag
}

module "emailservice" {
  source = "./services/emailservice"
  
  namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag = var.image_tag
}

module "checkoutservice" {
  source = "./services/checkoutservice"
  
  namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag = var.image_tag
}

module "recommendationservice" {
  source = "./services/recommendationservice"
  
  namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag = var.image_tag
}

module "adservice" {
  source = "./services/adservice"
  
  namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  image_tag = var.image_tag
}
