resource "kubernetes_deployment" "adservice" {
  metadata {
    name      = "adservice"
    namespace = var.namespace
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
    namespace = var.namespace
  }
  spec {
    port {
      port        = 9555
      target_port = 9555
    }
    selector = { app = "adservice" }
  }
}
