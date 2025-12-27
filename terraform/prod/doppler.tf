locals {
  secrets_config = [
    {
      name  = "AWS_ACCESS_KEY_ID"
      value = var.aws_access_key_id
    },
    {
      name  = "AWS_SECRET_ACCESS_KEY"
      value = var.aws_secret_access_key
    },
    {
      name  = "AWS_REGION"
      value = local.aws_region
    },
    {
      name  = "TS_CLIENT_ID"
      value = var.ts_client_id
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
      name  = "GHCR_DOCKERCONFIGJSON"
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
      name  = "ES_PASSWORD"
      value = var.es_password
    }
  ]
}

resource "doppler_secret" "secret" {
  for_each = { for secret in local.secrets_config : secret.name => secret }
  project = "prod"
  config  = "prd"
  name    = each.value.name
  value   = each.value.value
}
