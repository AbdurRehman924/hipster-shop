# Namespace
resource "kubernetes_namespace" "hipster_shop" {
  metadata {
    name = "hipster-shop"
  }
}

# Redis Secret
resource "kubernetes_secret" "redis" {
  metadata {
    name      = "redis-secret"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  data = {
    host     = digitalocean_database_cluster.redis.host
    port     = digitalocean_database_cluster.redis.port
    password = digitalocean_database_cluster.redis.password
  }
}

# Frontend Service
resource "kubernetes_deployment" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "frontend" }
    }
    template {
      metadata {
        labels = { app = "frontend" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/frontend:${var.image_tag}"
          port {
            container_port = 8080
          }
          env {
            name  = "PORT"
            value = "8080"
          }
          env {
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice:3550"
          }
          env {
            name  = "CURRENCY_SERVICE_ADDR"
            value = "currencyservice:7000"
          }
          env {
            name  = "CART_SERVICE_ADDR"
            value = "cartservice:7070"
          }
          env {
            name  = "RECOMMENDATION_SERVICE_ADDR"
            value = "recommendationservice:8080"
          }
          env {
            name  = "SHIPPING_SERVICE_ADDR"
            value = "shippingservice:50051"
          }
          env {
            name  = "CHECKOUT_SERVICE_ADDR"
            value = "checkoutservice:5050"
          }
          env {
            name  = "AD_SERVICE_ADDR"
            value = "adservice:9555"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name      = "frontend"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 8080
    }
    selector = { app = "frontend" }
  }
}

# Cart Service
resource "kubernetes_deployment" "cartservice" {
  metadata {
    name      = "cartservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "cartservice" }
    }
    template {
      metadata {
        labels = { app = "cartservice" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/cartservice:${var.image_tag}"
          port {
            container_port = 7070
          }
          env {
            name = "REDIS_ADDR"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.redis.metadata[0].name
                key  = "host"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "cartservice" {
  metadata {
    name      = "cartservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    port {
      port        = 7070
      target_port = 7070
    }
    selector = { app = "cartservice" }
  }
}

# Product Catalog Service
resource "kubernetes_deployment" "productcatalogservice" {
  metadata {
    name      = "productcatalogservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "productcatalogservice" }
    }
    template {
      metadata {
        labels = { app = "productcatalogservice" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/productcatalogservice:${var.image_tag}"
          port {
            container_port = 3550
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "productcatalogservice" {
  metadata {
    name      = "productcatalogservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    port {
      port        = 3550
      target_port = 3550
    }
    selector = { app = "productcatalogservice" }
  }
}

# Currency Service
resource "kubernetes_deployment" "currencyservice" {
  metadata {
    name      = "currencyservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "currencyservice" }
    }
    template {
      metadata {
        labels = { app = "currencyservice" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/currencyservice:${var.image_tag}"
          port {
            container_port = 7000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "currencyservice" {
  metadata {
    name      = "currencyservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    port {
      port        = 7000
      target_port = 7000
    }
    selector = { app = "currencyservice" }
  }
}

# Payment Service
resource "kubernetes_deployment" "paymentservice" {
  metadata {
    name      = "paymentservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "paymentservice" }
    }
    template {
      metadata {
        labels = { app = "paymentservice" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/paymentservice:${var.image_tag}"
          port {
            container_port = 50051
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "paymentservice" {
  metadata {
    name      = "paymentservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    port {
      port        = 50051
      target_port = 50051
    }
    selector = { app = "paymentservice" }
  }
}

# Shipping Service
resource "kubernetes_deployment" "shippingservice" {
  metadata {
    name      = "shippingservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "shippingservice" }
    }
    template {
      metadata {
        labels = { app = "shippingservice" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/shippingservice:${var.image_tag}"
          port {
            container_port = 50051
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "shippingservice" {
  metadata {
    name      = "shippingservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    port {
      port        = 50051
      target_port = 50051
    }
    selector = { app = "shippingservice" }
  }
}

# Email Service
resource "kubernetes_deployment" "emailservice" {
  metadata {
    name      = "emailservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "emailservice" }
    }
    template {
      metadata {
        labels = { app = "emailservice" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/emailservice:${var.image_tag}"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "emailservice" {
  metadata {
    name      = "emailservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    port {
      port        = 5000
      target_port = 8080
    }
    selector = { app = "emailservice" }
  }
}

# Checkout Service
resource "kubernetes_deployment" "checkoutservice" {
  metadata {
    name      = "checkoutservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "checkoutservice" }
    }
    template {
      metadata {
        labels = { app = "checkoutservice" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/checkoutservice:${var.image_tag}"
          port {
            container_port = 5050
          }
          env {
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice:3550"
          }
          env {
            name  = "SHIPPING_SERVICE_ADDR"
            value = "shippingservice:50051"
          }
          env {
            name  = "PAYMENT_SERVICE_ADDR"
            value = "paymentservice:50051"
          }
          env {
            name  = "EMAIL_SERVICE_ADDR"
            value = "emailservice:5000"
          }
          env {
            name  = "CURRENCY_SERVICE_ADDR"
            value = "currencyservice:7000"
          }
          env {
            name  = "CART_SERVICE_ADDR"
            value = "cartservice:7070"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "checkoutservice" {
  metadata {
    name      = "checkoutservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    port {
      port        = 5050
      target_port = 5050
    }
    selector = { app = "checkoutservice" }
  }
}

# Recommendation Service
resource "kubernetes_deployment" "recommendationservice" {
  metadata {
    name      = "recommendationservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "recommendationservice" }
    }
    template {
      metadata {
        labels = { app = "recommendationservice" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/recommendationservice:${var.image_tag}"
          port {
            container_port = 8080
          }
          env {
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice:3550"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "recommendationservice" {
  metadata {
    name      = "recommendationservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    port {
      port        = 8080
      target_port = 8080
    }
    selector = { app = "recommendationservice" }
  }
}

# Ad Service
resource "kubernetes_deployment" "adservice" {
  metadata {
    name      = "adservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "adservice" }
    }
    template {
      metadata {
        labels = { app = "adservice" }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/adservice:${var.image_tag}"
          port {
            container_port = 9555
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "adservice" {
  metadata {
    name      = "adservice"
    namespace = kubernetes_namespace.hipster_shop.metadata[0].name
  }
  spec {
    port {
      port        = 9555
      target_port = 9555
    }
    selector = { app = "adservice" }
  }
}
