locals {
  github_variables = {
    infra_ORG = {
      repository    = "infra"
      variable_name = "ORG"
      value         = local.org
    }
  }

  github_secrets = {
    infra_GH_ACCESS_TOKEN = {
      repository  = "infra"
      secret_name = "GH_ACCESS_TOKEN"
      value       = var.gh_access_token
    }
    infra_DP_TOKEN = {
      repository  = "infra"
      secret_name = "DP_TOKEN"
      value       = var.dp_token
    }
    infra_TS_OAUTH_CLIENT_ID = {
      repository  = "infra"
      secret_name = "TS_OAUTH_CLIENT_ID"
      value       = var.ts_oauth_client_id
    }
    infra_TS_OAUTH_SECRET = {
      repository  = "infra"
      secret_name = "TS_OAUTH_SECRET"
      value       = var.ts_oauth_client_secret
    }
    infra_BACKUPS_ACCESS_KEY_ID = {
      repository  = "infra"
      secret_name = "BACKUPS_ACCESS_KEY_ID"
      value       = var.backups_access_key_id
    }
    infra_BACKUPS_SECRET_ACCESS_KEY = {
      repository  = "infra"
      secret_name = "BACKUPS_SECRET_ACCESS_KEY"
      value       = var.backups_secret_access_key
    }
    infra_CF_ACCOUNT_ID = {
      repository  = "infra"
      secret_name = "CF_ACCOUNT_ID"
      value       = var.cf_account_id
    }
    infra_AWS_ACCESS_KEY_ID = {
      repository  = "infra"
      secret_name = "AWS_ACCESS_KEY_ID"
      value       = var.aws_access_key_id
    }
    infra_AWS_SECRET_ACCESS_KEY = {
      repository  = "infra"
      secret_name = "AWS_SECRET_ACCESS_KEY"
      value       = var.aws_secret_access_key
    }
    infra_CF_API_TOKEN = {
      repository  = "infra"
      secret_name = "CF_API_TOKEN"
      value       = var.cf_api_token
    }
    infra_CF_IP812_ZONE_ID = {
      repository  = "infra"
      secret_name = "CF_IP812_ZONE_ID"
      value       = var.cf_ip812_zone_id
    }
    infra_CF_TUNNEL_SECRET = {
      repository  = "infra"
      secret_name = "CF_TUNNEL_SECRET"
      value       = var.cf_tunnel_secret
    }
    infra_TS_TAILNET = {
      repository  = "infra"
      secret_name = "TS_TAILNET"
      value       = var.ts_tailnet
    }
    infra_PGADMIN_EMAIL = {
      repository  = "infra"
      secret_name = "PGADMIN_EMAIL"
      value       = var.pgadmin_email
    }
    infra_PGADMIN_PASSWORD = {
      repository  = "infra"
      secret_name = "PGADMIN_PASSWORD"
      value       = var.pgadmin_password
    }
    infra_PG_USERNAME = {
      repository  = "infra"
      secret_name = "PG_USERNAME"
      value       = var.pg_username
    }
    infra_PG_PASSWORD = {
      repository  = "infra"
      secret_name = "PG_PASSWORD"
      value       = var.pg_password
    }
    infra_FD_EMAIL_1 = {
      repository  = "infra"
      secret_name = "FD_EMAIL_1"
      value       = var.fd_email_1
    }
    infra_FD_EMAIL_2 = {
      repository  = "infra"
      secret_name = "FD_EMAIL_2"
      value       = var.fd_email_2
    }
    lambdas_AWS_ACCESS_KEY_ID = {
      repository  = "lambdas"
      secret_name = "AWS_ACCESS_KEY_ID"
      value       = var.aws_access_key_id
    }
    lambdas_AWS_SECRET_ACCESS_KEY = {
      repository  = "lambdas"
      secret_name = "AWS_SECRET_ACCESS_KEY"
      value       = var.aws_secret_access_key
    }
    lambdas_AWS_REGION = {
      repository  = "lambdas"
      secret_name = "AWS_REGION"
      value       = local.aws_region
    }
    lambdas_GH_ACCESS_TOKEN = {
      repository  = "lambdas"
      secret_name = "GH_ACCESS_TOKEN"
      value       = var.gh_access_token
    }
    go-template_GH_ACCESS_TOKEN = {
      repository  = "go-template"
      secret_name = "GH_ACCESS_TOKEN"
      value       = var.gh_access_token
    }
    blog_GH_ACCESS_TOKEN = {
      repository  = "blog"
      secret_name = "GH_ACCESS_TOKEN"
      value       = var.gh_access_token
    }
  }
}

resource "github_actions_variable" "this" {
  for_each      = local.github_variables
  repository    = each.value.repository
  variable_name = each.value.variable_name
  value         = each.value.value
}

resource "github_actions_secret" "this" {
  for_each    = local.github_secrets
  repository  = each.value.repository
  secret_name = each.value.secret_name
  value       = each.value.value
}
