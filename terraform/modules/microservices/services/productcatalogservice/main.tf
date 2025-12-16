resource "kubernetes_deployment" "productcatalogservice" {
  metadata {
    name      = "productcatalogservice"
    namespace = var.namespace
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
    namespace = var.namespace
  }
  spec {
    port {
      port        = 3550
      target_port = 3550
    }
    selector = { app = "productcatalogservice" }
  }
}
