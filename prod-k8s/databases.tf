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

data "external" "chart_hash_pgadmin" {
  program = ["bash", "-c", <<-EOT
    find "${path.module}/charts/pgadmin" -type f -print0 \
    | sort -z \
    | xargs -0 sha256sum \
    | sha256sum \
    | jq -Rn '{"hash": input}'
  EOT
  ]
}

resource "helm_release" "pgadmin" {
  depends_on = [
    kubernetes_namespace.databases,
    helm_release.cnpg_cloudnative_pg
  ]

  name         = "pgadmin"
  namespace    = kubernetes_namespace.databases.metadata[0].name
  chart        = "${path.module}/charts/pgadmin"
  repository   = ""
  version      = "0.1.0"
  force_update = true
  wait         = true
  timeout      = 600

  values = [
    yamlencode({
      # dummy values to ensure the chart is always updated
      chartContentHash = trimspace(data.external.chart_hash_pgadmin.result["hash"])

      pgadminEmail = data.terraform_remote_state.prod.outputs.pgadmin_email
      pgadminPassword = data.terraform_remote_state.prod.outputs.pgadmin_password
    })
  ]
}
