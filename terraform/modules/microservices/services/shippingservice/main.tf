resource "kubernetes_deployment" "shippingservice" {
  metadata {
    name      = "shippingservice"
    namespace = var.namespace
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
    namespace = var.namespace
  }
  spec {
    port {
      port        = 50051
      target_port = 50051
    }
    selector = { app = "shippingservice" }
  }
}
