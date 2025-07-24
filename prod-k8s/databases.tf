resource "kubernetes_namespace" "databases" {
  metadata {
    name = "databases"
  }
}

resource "helm_release" "cnpg_cloudnative_pg" {
  name       = "cnpg-cloudnative-pg"
  repository = "https://cloudnative-pg.github.io/charts"
  chart      = "cloudnative-pg"
  version    = "0.24.0"
  namespace  = kubernetes_namespace.databases.metadata[0].name
  wait       = true
  timeout    = 600
}
