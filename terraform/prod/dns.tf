locals {
  route_config = {
    proxmox = {
      is_protected = false
      proxied      = false
      ip           = var.home_public_ip
    }
    blog = {
      is_protected = false
      tunnel       = cloudflare_zero_trust_tunnel_cloudflared.cf_shoot_work_01_tunnel
    }
    clickstack = {
      is_protected = false
      tunnel       = cloudflare_zero_trust_tunnel_cloudflared.cf_gardener_o11y_signal_externalization_tunnel
    }
    elk = {
      is_protected = false
      tunnel       = cloudflare_zero_trust_tunnel_cloudflared.cf_gardener_o11y_signal_externalization_tunnel
    }
    influxdb = {
      is_protected = false
      tunnel       = cloudflare_zero_trust_tunnel_cloudflared.cf_gardener_o11y_signal_externalization_tunnel
    }
  }
}

resource "cloudflare_dns_record" "dns_record" {
  for_each = local.route_config
  zone_id  = var.cf_ip812_zone_id
  name     = "${each.key}.${local.org}.com"
  content  = try(each.value.tunnel, null) != null ? "${each.value.tunnel.id}.cfargotunnel.com" : each.value.ip
  type     = try(each.value.tunnel, null) != null ? "CNAME" : "A"
  ttl      = 1
  proxied  = try(each.value.proxied, true)
}

import {
  to = cloudflare_dns_record.dns_record["proxmox"]
  id = "${var.cf_ip812_zone_id}/c36f0e4d44ea32124e431db0c672c8e8"
}

resource "cloudflare_zero_trust_access_policy" "zt_access_policy" {
  account_id       = var.cf_account_id
  name             = "Admin allowlist"
  decision         = "allow"
  session_duration = "8h"

  include = [{
    email = {
      email = var.fd_email_1
    }
  }]
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
