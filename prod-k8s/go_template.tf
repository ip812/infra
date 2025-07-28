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

locals {
  docker_config_json_sensitive = sensitive(base64encode(jsonencode({
    auths = {
      "ghcr.io" = {
        username = data.terraform_remote_state.prod.outputs.gh_username
        password = data.terraform_remote_state.prod.outputs.gh_access_token
        auth     = base64encode("${data.terraform_remote_state.prod.outputs.gh_username}:${data.terraform_remote_state.prod.outputs.gh_access_token}")
      }
    }
  })))
}

locals {
  values_yaml = templatefile("${path.module}/values/go-template.values.yaml.tmpl", {
    # dummy value to ensure the chart is always updated
    chart_hash = trimspace(data.external.chart_hash_template.result["hash"])

    pg_db              = data.terraform_remote_state.prod.outputs.go_template_db_name
    pg_host            = "${data.terraform_remote_state.prod.outputs.go_template_db_name}-pg-rw.${kubernetes_namespace.template.metadata[0].name}.svc.cluster.local"
    pg_user            = data.terraform_remote_state.prod.outputs.pg_username
    pg_pass            = data.terraform_remote_state.prod.outputs.pg_password
    pg_bucket          = data.terraform_remote_state.prod.outputs.backups_bucket_name
    docker_config_json = local.docker_config_json_sensitive
  })
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
  values       = [local.values_yaml]
}
