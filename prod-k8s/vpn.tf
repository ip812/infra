resource "kubernetes_namespace" "vpn" {
  metadata {
    name = "vpn"
  }
}

data "external" "chart_hash_vpn" {
  program = ["bash", "-c", <<-EOT
    find "${path.module}/charts/tailscale-cleanup" -type f -print0 \
    | sort -z \
    | xargs -0 sha256sum \
    | sha256sum \
    | jq -Rn '{"hash": input}'
  EOT
  ]
}

locals {
  tailscale_cleanup_values_yaml = templatefile("${path.module}/values/tailscale-cleanup.values.yaml.tmpl", {
    chart_hash = trimspace(data.external.chart_hash_template.result["hash"])
    ts_api_key = var.ts_api_key
    tailnet    = var.ts_tailnet
  })
}

resource "helm_release" "tailscale_cleanup" {
  depends_on = [
    kubernetes_namespace.vpn
  ]

  name         = "tailscale-cleanup"
  namespace    = kubernetes_namespace.vpn.metadata[0].name
  chart        = "${path.module}/charts/tailscale-cleanup"
  repository   = ""
  version      = "0.1.0"
  force_update = true
  wait         = true
  timeout      = 600
  values       = [local.tailscale_cleanup_values_yaml]
}

resource "helm_release" "tailscale_operator" {
  depends_on = [
    kubernetes_namespace.vpn,
    helm_release.tailscale_cleanup
  ]

  name       = "tailscale-operator"
  namespace  = kubernetes_namespace.vpn.metadata[0].name
  repository = "https://pkgs.tailscale.com/helmcharts"
  chart      = "tailscale-operator"
  version    = "1.84.3"
  wait       = true
  timeout    = 600

  set = [
    {
      name  = "oauth.clientId"
      value = var.ts_client_id
    },
    {
      name  = "oauth.clientSecret"
      value = var.ts_client_secret
    }
  ]
}
