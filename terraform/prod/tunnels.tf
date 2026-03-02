locals {
  tunnel_config = {
    template = {
      is_protected = false
    }
    blog = {
      is_protected = false
    }
    pgadmin = {
      is_protected = true
    }
    prometheus = {
      is_protected = true
    }
    # alertmanager = {
    #   is_protected = true
    # }
    grafana = {
      is_protected = true
    }
    # kibana = {
    #   is_protected = true
    # }
    jaeger = {
      is_protected = true
    }
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "cf_tunnel" {
  account_id    = var.cf_account_id
  name          = local.cf_tunnel_name
  config_src    = "local"
  tunnel_secret = var.cf_tunnel_secret
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "cf_tunnel_token" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
}

resource "cloudflare_dns_record" "dns_record" {
  for_each = local.tunnel_config
  zone_id  = var.cf_ip812_zone_id
  name     = "${each.key}.${local.org}.com"
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id}.cfargotunnel.com"
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}

resource "cloudflare_zero_trust_access_policy" "zt_access_policy" {
  account_id       = var.cf_account_id
  name             = "Admin allowlist"
  decision         = "allow"
  session_duration = "8h"

  include = [
    for email in local.whitelist_emails : {
      email = {
        email = email
      }
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "zt_access_application" {
  for_each = {
    for key, cfg in local.tunnel_config :
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
