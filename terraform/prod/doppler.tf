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
