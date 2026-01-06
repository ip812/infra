locals {
  secrets_config = [
    {
      name  = "POSTGRES_BACKUPS_ACCESS_KEY_ID"
      value = var.pg_backups_access_key_id
    },
    {
      name  = "POSTGRES_BACKUPS_SECRET_ACCESS_KEY"
      value = var.pg_backups_secret_access_key
    },
    {
      name  = "TS_CLIENT_SECRET"
      value = var.ts_client_secret
    },
    {
      name  = "TS_API_KEY"
      value = var.ts_api_key
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
    },
    {
      name  = "TUNNEL_TOKEN"
      value = data.cloudflare_zero_trust_tunnel_cloudflared_token.cf_tunnel_token.token
    },
    {
      name  = "SLACK_BLOG_BOT_TOKEN"
      value = var.slk_blog_bot_token
    },
    {
      name  = "ELASTIC_USERNAME"
      value = var.es_username
    },
    {
      name  = "ELASTIC_PASSWORD"
      value = var.es_password
    },
    {
      name  = "GRAFANA_USERNAME"
      value = var.gf_username
    },
    {
      name  = "GRAFANA_PASSWORD"
      value = var.gf_password
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
