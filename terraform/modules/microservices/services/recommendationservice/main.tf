resource "kubernetes_deployment" "recommendationservice" {
  metadata {
    name      = "recommendationservice"
    namespace = var.namespace
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
    namespace = var.namespace
  }
  spec {
    port {
      port        = 8080
      target_port = 8080
    }
    selector = { app = "recommendationservice" }
  }
}
