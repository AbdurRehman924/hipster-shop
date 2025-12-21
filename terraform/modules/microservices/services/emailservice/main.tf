resource "kubernetes_deployment" "emailservice" {
  metadata {
    name      = "emailservice"
    namespace = var.namespace
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
    namespace = var.namespace
  }
  spec {
    port {
      port        = 5000
      target_port = 8080
    }
    selector = { app = "emailservice" }
  }
}
