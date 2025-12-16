locals {
  whitelist_emails = [
    "ilia.yavorov.petrov@gmail.com"
  ]
  config = {
    template = {
      k8s_ns       = "template",
      k8s_svc_name = "template-svc",
      k8s_svc_port = "8080",
      is_protected = false
    }
    blog = {
      k8s_ns       = "blog",
      k8s_svc_name = "blog-svc",
      k8s_svc_port = "8080",
      is_protected = false
    }
    pgadmin = {
      k8s_ns       = "database",
      k8s_svc_name = "pgadmin-svc",
      k8s_svc_port = "8080",
      is_protected = true
    }
    capacitor = {
      k8s_ns       = "monitoring",
      k8s_svc_name = "capacitor",
      k8s_svc_port = "9000",
      is_protected = true
    }
  }
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "cf_tunnel" {
  account_id    = var.cf_account_id
  name          = local.cf_tunnel_name
  config_src    = "cloudflare"
  tunnel_secret = var.cf_tunnel_secret
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "cf_tunnel_token" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
}

resource "cloudflare_dns_record" "dns_record" {
  for_each = local.config
  zone_id  = var.cf_ip812_zone_id
  name     = "${each.key}.${local.org}.com"
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id}.cfargotunnel.com"
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id

  config = {
    ingress = concat(
      [
        for key, cfg in local.config : {
          hostname = cloudflare_dns_record.dns_record[key].name
          service  = "http://${cfg.k8s_svc_name}.${cfg.k8s_ns}.svc.cluster.local:${cfg.k8s_svc_port}"
        }
      ],
      [
        {
          service = "http_status:404"
        }
      ]
    )
  }
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
    for key, cfg in local.config :
    key => cfg
    if cfg.is_protected
  }

  account_id                = var.cf_account_id
  name                      = "Prod Avalon Backoffice"
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
