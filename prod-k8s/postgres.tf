resource "helm_release" "cnpg_cloudnative_pg" {
  name             = "cnpg-cloudnative-pg"
  repository       = "https://cloudnative-pg.github.io/charts"
  chart            = "cloudnative-pg"
  namespace        = "databases"
  create_namespace = true
  wait             = false
  timeout          = 600
}
