resource "cloudflare_zero_trust_tunnel_cloudflared" "cf_tunnel" {
  account_id = var.cf_account_id
  name       = var.cf_tunnel_name
  secret     = var.cf_tunnel_secret
}

output "cf_tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
}

resource "cloudflare_record" "pgadmin_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = var.pgadmin_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

output "pgadmin_hostname" {
  value = cloudflare_record.pgadmin_dns_record.hostname
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

resource "cloudflare_record" "blog_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = var.blog_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

output "blog_hostname" {
  value = cloudflare_record.blog_dns_record.hostname
}

resource "cloudflare_record" "go_template_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = var.go_template_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

output "go_template_hostname" {
  value = cloudflare_record.go_template_dns_record.hostname
}
