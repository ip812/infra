resource "kubernetes_namespace" "vpn" {
  metadata {
    name = "vpn"
  }
}

resource "kubernetes_secret" "tailscale_auth" {
  metadata {
    name      = "tailscale-auth"
    namespace = kubernetes_namespace.vpn.metadata[0].name
  }

  data = {
    TS_AUTHKEY = data.terraform_remote_state.prod.outputs.ts_auth_key
  }

  type = "Opaque"
}
