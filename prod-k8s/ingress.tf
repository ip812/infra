resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress"
  }
}

data "external" "chart_hash_cf_tunnel" {
  program = ["bash", "-c", <<-EOT
    find "${path.module}/charts/cloudflare-tunnel" -type f -print0 \
    | sort -z \
    | xargs -0 sha256sum \
    | sha256sum \
    | jq -Rn '{"hash": input}'
  EOT
  ]
}

locals {
  cf_tunnel_values_yaml = templatefile("${path.module}/values/cloudflare-tunnel.values.yaml.tmpl", {
    # dummy value to ensure the chart is always updated
    chart_hash = trimspace(data.external.chart_hash_cf_tunnel.result["hash"])

    tunnel_token = data.terraform_remote_state.prod.outputs.cf_tunnel_token
  })
}

resource "helm_release" "cloudflare_tunnel" {
  depends_on = [
    kubernetes_namespace.ingress
  ]

  name         = "cloudflare-tunnel"
  namespace    = kubernetes_namespace.ingress.metadata[0].name
  chart        = "${path.module}/charts/cloudflare-tunnel"
  repository   = ""
  version      = "0.1.0"
  force_update = true
  wait         = true
  timeout      = 600
  values       = [local.cf_tunnel_values_yaml]
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
  account_id = data.terraform_remote_state.prod.outputs.cf_account_id
  tunnel_id  = data.terraform_remote_state.prod.outputs.cf_tunnel_id
  config = {
    ingress = [
      {
        hostname = data.terraform_remote_state.prod.outputs.go_template_hostname
        service  = "http://go-template-svc.${kubernetes_namespace.template}.svc.cluster.local:8080"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}
