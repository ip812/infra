resource "helm_release" "cnpg_cloudnative_pg" {
  name             = "cnpg-cloudnative-pg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  version          = "0.24.0"
  namespace        = "databases"
  create_namespace = true
  wait             = true
  timeout          = 600
}
