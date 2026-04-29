locals {
  route_config = {
    shoot-work-01 = {
      is_protected = true
      tunnel = cloudflare_zero_trust_tunnel_cloudflared.cf_shoot_work_01_tunnel
    }
    blog = {
      is_protected = false
      tunnel = cloudflare_zero_trust_tunnel_cloudflared.cf_shoot_work_01_tunnel
    }
    pgadmin = {
      is_protected = true
      tunnel = cloudflare_zero_trust_tunnel_cloudflared.cf_shoot_work_01_tunnel
    }
    victoria-logs = {
      is_protected = true
      tunnel = cloudflare_zero_trust_tunnel_cloudflared.cf_shoot_work_01_tunnel
    }
    victoria-traces = {
      is_protected = true
      tunnel = cloudflare_zero_trust_tunnel_cloudflared.cf_shoot_work_01_tunnel
    }
  }
}

resource "cloudflare_dns_record" "dns_record" {
  for_each = local.route_config
  zone_id  = var.cf_ip812_zone_id
  name     = "${each.key}.${local.org}.com"
  content  = "${each.value.tunnel.id}.cfargotunnel.com"
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}

resource "cloudflare_zero_trust_access_service_token" "work_to_o11y" {
  name       = "work-to-o11y"
  zone_id    = var.cf_ip812_zone_id
  duration   = "175200h" # 20 years
}

resource "cloudflare_zero_trust_access_policy" "zt_access_policy" {
  account_id       = var.cf_account_id
  name             = "Admin allowlist"
  decision         = "allow"
  session_duration = "8h"

  include = concat(
    [for email in local.whitelist_emails : {
      email = {
        email = email
      }
    }],
    [{
      service_token = {
        token_id = cloudflare_zero_trust_access_service_token.work_to_o11y.id
      }
    }]
  )
}

resource "cloudflare_zero_trust_access_application" "zt_access_application" {
  for_each = {
    for key, cfg in local.route_config :
    key => cfg
    if cfg.is_protected
  }

  account_id                = var.cf_account_id
  name                      = "${each.key} ${local.org} ${local.env}"
  domain                    = "${each.key}.${local.org}.com"
  type                      = "self_hosted"
  session_duration          = "8h"
  auto_redirect_to_identity = true

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.zt_access_policy.id
      precedence = 1
    }
  ]
}
