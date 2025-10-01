resource "doppler_secret" "gf_cloud_access_policy_token" {
  project = "prod"
  config  = "prod"
  name    = "GF_CLOUD_ACCESS_POLICY_TOKEN"
  value   = var.gf_cloud_access_policy_token
}
