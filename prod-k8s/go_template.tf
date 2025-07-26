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
      # dummy value to ensure the chart is always updated
      chartContentHash = trimspace(data.external.chart_hash_template.result["hash"])

      image             = "ghcr.io/iypetrov/go-template:1.6.0"
      isInit            = false
      pgDatabaseName    = data.terraform_remote_state.prod.outputs.go_template_db_name
      pgUsername        = data.terraform_remote_state.prod.outputs.pg_username
      pgPassword        = data.terraform_remote_state.prod.outputs.pg_password
      pgImage           = "ghcr.io/cloudnative-pg/postgresql:16.1"
      pgStorageSize     = "1Gi"
      pgRetentionPolicy = "7d"
      pgBackupsBucket   = data.terraform_remote_state.prod.outputs.backups_bucket_name
      pgBackupSchedule  = "0 0 0 * * *"
    })
  ]
}
