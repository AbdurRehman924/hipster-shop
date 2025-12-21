resource "kubernetes_deployment" "cartservice" {
  metadata {
    name      = "cartservice"
    namespace = var.namespace
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
          # Using in-memory storage instead of Redis
        }
      }
    }
  }
}

resource "kubernetes_service" "cartservice" {
  metadata {
    name      = "cartservice"
    namespace = var.namespace
  }
  spec {
    port {
      port        = 7070
      target_port = 7070
    }
    selector = { app = "cartservice" }
  }
}
