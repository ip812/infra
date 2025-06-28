resource "kubernetes_namespace" "ip812_ns" {
  metadata {
    name = var.org
  }
}

resource "kubernetes_namespace" "foo" {
  metadata {
    name = "foo"
  }
}
