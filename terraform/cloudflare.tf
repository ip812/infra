resource "cloudflare_zero_trust_tunnel_cloudflared" "cf_tunnel" {
  account_id = var.cf_account_id
  name       = var.cf_tunnel_name
  secret     = var.cf_tunnel_secret
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
  config {
    ingress_rule {
      hostname = cloudflare_record.pgadmin_dns_record.hostname
      service  = "http://pgadmin-svc.ip812.svc.cluster.local:8080"
    }
    ingress_rule {
      hostname = cloudflare_record.go_template_dns_record.hostname
      service  = "http://go-template-svc.ip812.svc.cluster.local:8080"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_record" "go_template_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = var.go_template_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "pgadmin_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = var.pgadmin_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_zero_trust_access_application" "pgadmin_zt_app" {
  zone_id                   = var.cf_ip812_zone_id
  name                      = "pgadmin"
  domain                    = "pgadmin.${var.org}.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_zero_trust_access_policy" "pgadmin_ap" {
  zone_id        = var.cf_ip812_zone_id
  application_id = cloudflare_zero_trust_access_application.pgadmin_zt_app.id
  name           = "pgadmin"
  decision       = "allow"
  precedence     = 1
  include {
    email = var.whitelist_email_addresses
  }
}
