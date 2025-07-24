resource "kubernetes_namespace" "vpn" {
  metadata {
    name = "vpn"
  }
}

resource "helm_release" "tailscale_operator" {
  name       = "tailscale-operator"
  namespace  = kubernetes_namespace.vpn.metadata[0].name
  repository = "https://pkgs.tailscale.com/helmcharts"
  chart      = "tailscale-operator"
  version    = "1.84.3"
  wait       = true
  timeout    = 600

  set {
    name  = "oauth.clientId"
    value = var.ts_client_id
  }

  set {
    name  = "oauth.clientSecret"
    value = var.ts_client_secret
  }
}
