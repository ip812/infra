locals {
  secrets_config = [
    {
      name  = "POSTGRES_BACKUPS_ACCESS_KEY_ID"
      value = var.backups_access_key_id
    },
    {
      name  = "POSTGRES_BACKUPS_SECRET_ACCESS_KEY"
      value = var.backups_secret_access_key
    },
    {
      name  = "TS_TAILNET"
      value = local.ts_tailnet
    },
    {
      name  = "PG_USERNAME"
      value = var.pg_username
    },
    {
      name  = "PG_PASSWORD"
      value = var.pg_password
    },
    {
      name  = "PGADMIN_EMAIL"
      value = var.pgadmin_email
    },
    {
      name  = "PGADMIN_PASSWORD"
      value = var.pgadmin_password
    },
    {
      name  = "TUNNEL_SHOOT_WORK_01_TOKEN"
      value = data.cloudflare_zero_trust_tunnel_cloudflared_token.cf_shoot_work_01_tunnel_token.token
    },
    {
      name  = "TUNNEL_SHOOT_O11Y_01_TOKEN"
      value = data.cloudflare_zero_trust_tunnel_cloudflared_token.cf_shoot_o11y_01_tunnel_token.token
    },
    {
      name = "GHCR_DOCKERCONFIGJSON"
      value = jsonencode({
        auths = {
          "ghcr.io" = {
            username = local.gh_username
            password = var.gh_access_token
            auth     = base64encode("${local.gh_username}:${var.gh_access_token}")
          }
        }
      })
    }
  ]
}

resource "doppler_secret" "secret" {
  for_each = { for secret in local.secrets_config : secret.name => secret }
  project  = "prod"
  config   = "prd"
  name     = each.value.name
  value    = each.value.value
}
