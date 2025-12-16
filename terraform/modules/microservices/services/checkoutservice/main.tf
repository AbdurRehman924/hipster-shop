resource "kubernetes_deployment" "checkoutservice" {
  metadata {
    name      = "checkoutservice"
    namespace = var.namespace
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
    namespace = var.namespace
  }
  spec {
    port {
      port        = 5050
      target_port = 5050
    }
    selector = { app = "checkoutservice" }
  }
}
