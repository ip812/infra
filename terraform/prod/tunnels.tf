resource "cloudflare_zero_trust_tunnel_cloudflared" "cf_shoot_work_01_tunnel" {
  account_id    = var.cf_account_id
  name          = local.cf_shoot_work_01_tunnel_name
  config_src    = "local"
  tunnel_secret = var.cf_tunnel_secret
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "cf_shoot_work_01_tunnel_token" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_shoot_work_01_tunnel.id
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "cf_shoot_o11y_01_tunnel" {
  account_id    = var.cf_account_id
  name          = local.cf_shoot_o11y_01_tunnel_name
  config_src    = "local"
  tunnel_secret = var.cf_tunnel_secret
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "cf_shoot_o11y_01_tunnel_token" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_shoot_o11y_01_tunnel.id
}
