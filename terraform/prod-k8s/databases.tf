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

locals {
  pgadmin_values_yaml = sensitive(templatefile("${path.module}/values/pgadmin.values.yaml.tmpl", {
    # dummy value to ensure the chart is always updated
    chart_hash = trimspace(data.external.chart_hash_pgadmin.result["hash"])

    pgadminEmail    = data.terraform_remote_state.prod.outputs.pgadmin_email
    pgadminPassword = data.terraform_remote_state.prod.outputs.pgadmin_password
    servers = [
      {
        name     = "go-template"
        database = data.terraform_remote_state.prod.outputs.go_template_db_name
        host     = "${data.terraform_remote_state.prod.outputs.go_template_db_name}-pg-rw.${kubernetes_namespace.template.metadata[0].name}.svc.cluster.local"
        username = data.terraform_remote_state.prod.outputs.pg_username
      },
      {
        name     = "blog"
        database = data.terraform_remote_state.prod.outputs.blog_db_name
        host     = "${data.terraform_remote_state.prod.outputs.blog_db_name}-pg-rw.${kubernetes_namespace.blog.metadata[0].name}.svc.cluster.local"
        username = data.terraform_remote_state.prod.outputs.pg_username
      }
    ]
  }))
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
  values       = [local.pgadmin_values_yaml]
}
