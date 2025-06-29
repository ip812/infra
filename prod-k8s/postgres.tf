resource "kubernetes_namespace" "database" {
  metadata {
    name = "database"
  }
}
