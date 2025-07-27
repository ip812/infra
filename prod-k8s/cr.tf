resource "kubernetes_namespace" "cr" {
  metadata {
    name = "cr"
  }
}

resource "kubernetes_secret" "ghcr_docker_config" {
  metadata {
    name      = "ghcr-auth"
    namespace = kubernetes_namespace.cr.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = base64encode(jsonencode({
      auths = {
        "ghcr.io" = {
          username = data.terraform_remote_state.prod.outputs.gh_username
          password = data.terraform_remote_state.prod.outputs.gh_access_token
          auth     = base64encode("${data.terraform_remote_state.prod.outputs.gh_username}:${data.terraform_remote_state.prod.outputs.gh_access_token}")
        }
      }
    }))
  }
}
