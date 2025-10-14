resource "doppler_secret" "aws_access_key_id" {
  project = "prod"
  config  = "prd"
  name    = "AWS_ACCESS_KEY_ID"
  value   = var.aws_access_key_id
}

resource "doppler_secret" "aws_secret_access_key" {
  project = "prod"
  config  = "prd"
  name    = "AWS_SECRET_ACCESS_KEY"
  value   = var.aws_secret_access_key
} 

resource "doppler_secret" "aws_region" {
  project = "prod"
  config  = "prd"
  name    = "AWS_REGION"
  value   = var.aws_region
}

resource "doppler_secret" "gf_cloud_access_policy_token" {
  project = "prod"
  config  = "prd"
  name    = "GF_CLOUD_ACCESS_POLICY_TOKEN"
  value   = var.gf_cloud_access_policy_token
}

resource "doppler_secret" "gf_cloud_prometheus_user_id" {
  project = "prod"
  config  = "prd"
  name    = "GF_CLOUD_PROMETHEUS_USER_ID"
  value   = grafana_cloud_stack.stack.prometheus_user_id
}

resource "doppler_secret" "gf_cloud_logs_user_id" {
  project = "prod"
  config  = "prd"
  name    = "GF_CLOUD_LOGS_USER_ID"
  value   = grafana_cloud_stack.stack.logs_user_id
}

resource "doppler_secret" "gf_cloud_profiles_user_id" {
  project = "prod"
  config  = "prd"
  name    = "GF_CLOUD_PROFILES_USER_ID"
  value   = grafana_cloud_stack.stack.profiles_user_id
}

resource "doppler_secret" "ts_client_id" {
  project = "prod"
  config  = "prd"
  name    = "TS_CLIENT_ID"
  value   = var.ts_client_id
}

resource "doppler_secret" "ts_client_secret" {
  project = "prod"
  config  = "prd"
  name    = "TS_CLIENT_SECRET"
  value   = var.ts_client_secret
}

resource "doppler_secret" "ts_api_key" {
  project = "prod"
  config  = "prd"
  name    = "TS_API_KEY"
  value   = var.ts_api_key
}

resource "doppler_secret" "ts_tailnet" {
  project = "prod"
  config  = "prd"
  name    = "TS_TAILNET"
  value   = var.ts_tailnet
}

resource "doppler_secret" "pg_username" {
  project = "prod"
  config  = "prd"
  name    = "PG_USERNAME"
  value   = var.pg_username
}

resource "doppler_secret" "pg_password" {
  project = "prod"
  config  = "prd"
  name    = "PG_PASSWORD"
  value   = var.pg_password
}

resource "doppler_secret" "pgadmin_email" {
  project = "prod"
  config  = "prd"
  name    = "PGADMIN_EMAIL"
  value   = var.pgadmin_email
}

resource "doppler_secret" "pgadmin_password" {
  project = "prod"
  config  = "prd"
  name    = "PGADMIN_PASSWORD"
  value   = var.pgadmin_password
}

resource "doppler_secret" "ghcr_dockerconfigjson" {
  project = "prod"
  config  = "prd"
  name    = "GHCR_DOCKERCONFIGJSON"
  value   = jsonencode({
    auths = {
      "ghcr.io" = {
        username = var.gh_username
        password = var.gh_access_token
        auth     = base64encode("${var.gh_username}:${var.gh_access_token}")
      }
    }
  })
}
