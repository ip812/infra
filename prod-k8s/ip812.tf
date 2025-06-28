resource "kubernetes_namespace" "ip812" {
  metadata {
    name = var.org
  }
}
