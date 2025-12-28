resource "kubernetes_deployment" "currencyservice" {
  metadata {
    name      = "currencyservice"
    namespace = var.namespace
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

          env {
            name  = "PORT"
            value = "7000"
          }

          env {
            name  = "DISABLE_PROFILER"
            value = "true"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "currencyservice" {
  metadata {
    name      = "currencyservice"
    namespace = var.namespace
  }

  spec {
    port {
      port        = 7000
      target_port = 7000
    }
    selector = { app = "currencyservice" }
  }
}
