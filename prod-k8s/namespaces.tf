resource "kubernetes_namespace" "ip812_ns" {
  metadata {
    name = var.org
  }
}
