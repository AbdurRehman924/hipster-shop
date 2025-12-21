resource "kubernetes_deployment" "paymentservice" {
  metadata {
    name      = "paymentservice"
    namespace = var.namespace
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
    namespace = var.namespace
  }
  spec {
    port {
      port        = 50051
      target_port = 50051
    }
    selector = { app = "paymentservice" }
  }
}
