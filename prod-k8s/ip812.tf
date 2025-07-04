resource "kubernetes_namespace" "ip812" {
  metadata {
    name = var.org
  }
}

resource "helm_release" "app_pg" {
  depends_on = [
    kubernetes_namespace.ip812
  ]
  name       = "app-pg"
  namespace  = kubernetes_namespace.ip812.metadata[0].name
  chart      = "${path.module}/charts/app-pg"
  repository = ""
  version = "0.1.0"
  force_update = true
  wait             = false
  timeout          = 600
}
