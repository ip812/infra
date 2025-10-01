resource "kubernetes_namespace" "blog" {
  metadata {
    name = "blog"
  }
}

resource "kubernetes_secret" "blog_ghcr_auth" {
  metadata {
    name      = "ghcr-auth"
    namespace = kubernetes_namespace.blog.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = data.terraform_remote_state.prod.outputs.gh_username
          password = data.terraform_remote_state.prod.outputs.gh_access_token
          auth     = base64encode("${data.terraform_remote_state.prod.outputs.gh_username}:${data.terraform_remote_state.prod.outputs.gh_access_token}")
        }
      }
    })
  }
}

data "external" "chart_hash_blog" {
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
  blog_values_yaml = sensitive(templatefile("${path.module}/values/blog.values.yaml.tmpl", {
    # dummy value to ensure the chart is always updated
    chart_hash = trimspace(data.external.chart_hash_blog.result["hash"])

    hostname           = data.terraform_remote_state.prod.outputs.blog_hostname
    pg_db              = data.terraform_remote_state.prod.outputs.blog_db_name
    pg_host            = "${data.terraform_remote_state.prod.outputs.blog_db_name}-pg-rw.${kubernetes_namespace.blog.metadata[0].name}.svc.cluster.local"
    pg_user            = data.terraform_remote_state.prod.outputs.pg_username
    pg_pass            = data.terraform_remote_state.prod.outputs.pg_password
    pg_bucket          = data.terraform_remote_state.prod.outputs.backups_bucket_name
    slk_general_channel_id = var.slk_general_channel_id
    slk_blog_bot_token = var.slk_blog_bot_token
  }))
}

resource "helm_release" "blog_app_pg" {
  depends_on = [
    kubernetes_namespace.blog,
    helm_release.cnpg_cloudnative_pg
  ]

  name         = "blog"
  namespace    = kubernetes_namespace.blog.metadata[0].name
  chart        = "${path.module}/charts/app-pg"
  repository   = ""
  version      = "0.1.0"
  force_update = true
  wait         = true
  timeout      = 600
  values       = [local.blog_values_yaml]
}
