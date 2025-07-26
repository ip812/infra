resource "kubernetes_namespace" "template" {
  metadata {
    name = "template"
  }
}

data "external" "chart_hash_template" {
  program = ["bash", "-c", <<-EOT
    find "${path.module}/charts/app-pg" -type f -print0 \
    | sort -z \
    | xargs -0 sha256sum \
    | sha256sum \
    | jq -Rn '{"hash": input}'
  EOT
  ]
}

resource "helm_release" "template_app_pg" {
  depends_on = [
    kubernetes_namespace.template,
    helm_release.cnpg_cloudnative_pg
  ]

  name         = "go-template"
  namespace    = kubernetes_namespace.template.metadata[0].name
  chart        = "${path.module}/charts/app-pg"
  repository   = ""
  version      = "0.1.0"
  force_update = true
  wait         = true
  timeout      = 600

  values = [
    yamlencode({
      # dummy values to ensure the chart is always updated
      chartContentHash = trimspace(data.external.chart_hash_template.result["hash"])

      isInit          = false
      database        = data.terraform_remote_state.prod.outputs.go_template_db_name
      username        = data.terraform_remote_state.prod.outputs.pg_username
      password        = data.terraform_remote_state.prod.outputs.pg_password
      image           = "ghcr.io/cloudnative-pg/postgresql:16.1"
      storageSize     = "1Gi"
      retentionPolicy = "7d"
      backupsBucket   = data.terraform_remote_state.prod.outputs.backups_bucket_name
      backupSchedule  = "0 0 0 * * *"
    })
  ]
}
