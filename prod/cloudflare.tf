resource "cloudflare_zero_trust_tunnel_cloudflared" "ip812_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "ip812_tunnel"
  secret     = var.ip812_tunnel_secret
}

resource "cloudflare_record" "traefik_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = "traefik"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.ip812_tunnel.cname}"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "portainer_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = "portainer"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.ip812_tunnel.cname}"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "blog_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = var.blog_domain
  content = "${cloudflare_zero_trust_tunnel_cloudflared.ip812_tunnel.cname}"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "ip812_tunnel_cfg" {
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.ip812_tunnel.id
  account_id = var.cloudflare_account_id
  config {
    ingress_rule {
      hostname = cloudflare_record.traefik_dns_record.hostname
      service  = "http://traefik:80"
    }
    ingress_rule {
      hostname = cloudflare_record.portainer_dns_record.hostname
      service  = "http://traefik:80"
    }
    ingress_rule {
      hostname = cloudflare_record.blog_dns_record.hostname
      service  = "http://traefik:80"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_zero_trust_access_application" "traefik_zt_app" {
  zone_id                   = var.cloudflare_blog_zone_id
  name                      = "traefik"
  domain                    = "traefik.deviliablog.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_access_policy" "traefik_ap" {
  account_id     = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.traefik_zt_app.id
  name           = var.organization
  decision       = "allow"
  precedence     = 1

  include {
    email = var.whitelist_email_addresses
  }
}

resource "cloudflare_zero_trust_access_application" "portainer_zt_app" {
  zone_id                   = var.cloudflare_blog_zone_id
  name                      = "portainer"
  domain                    = "portainer.deviliablog.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_access_policy" "portainer_ap" {
  account_id     = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.portainer_zt_app.id
  name           = var.organization
  decision       = "allow"
  precedence     = 1

  include {
    email = var.whitelist_email_addresses
  }
}

resource "cloudflare_zero_trust_access_application" "blog_zt_app" {
  zone_id                   = var.cloudflare_blog_zone_id
  name                      = "blog"
  domain                    = "deviliablog.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}
