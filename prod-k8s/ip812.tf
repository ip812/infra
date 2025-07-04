resource "kubernetes_namespace" "ip812" {
  metadata {
    name = var.org
  }
}

data "external" "chart_hash" {
  program = ["bash", "-c", <<-EOT
    find "${path.module}/charts/app-pg" -type f -print0 \
    | sort -z \
    | xargs -0 sha256sum \
    | sha256sum \
    | jq -Rn '{"hash": input}'
  EOT
  ]
}

resource "helm_release" "app_pg" {
  depends_on = [kubernetes_namespace.ip812]

  name       = "app-pg"
  namespace  = kubernetes_namespace.ip812.metadata[0].name
  chart      = "${path.module}/charts/app-pg"
  repository = ""
  version    = "0.1.0"
  wait          = false
  timeout       = 600

  # dummy value to trigger update on chart changes
  set {
    name  = "chartContentHash"
    value = trimspace(data.external.chart_hash.result["hash"])
  }
}
