resource "cloudflare_record" "argocd_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = "argocd"
  content = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_zero_trust_access_application" "argocd_zt_app" {
  zone_id                   = var.cf_ip812_zone_id
  name                      = "argocd"
  domain                    = "argocd.${var.org}.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_zero_trust_access_policy" "argocd_ap" {
  zone_id        = var.cf_ip812_zone_id
  application_id = cloudflare_zero_trust_access_application.argocd_zt_app.id
  name           = "argocd"
  decision       = "allow"
  precedence     = 1
  include {
    email = var.whitelist_email_addresses
  }
}
