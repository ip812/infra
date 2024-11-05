################################################################################
#                                     DNS                                      #
################################################################################

resource "cloudflare_record" "traefik_dns_record" {
  zone_id = var.cloudflare_ip812_zone_id
  name    = "traefik"
  content = cloudflare_zero_trust_tunnel_cloudflared.tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_zero_trust_access_application" "traefik_zt_app" {
  zone_id                   = var.cloudflare_ip812_zone_id
  name                      = "traefik"
  domain                    = "traefik.ip812.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_zero_trust_access_policy" "traefik_ap" {
  zone_id        = var.cloudflare_ip812_zone_id
  application_id = cloudflare_zero_trust_access_application.traefik_zt_app.id
  name           = "traefik"
  decision       = "allow"
  precedence     = 1

  include {
    email = var.whitelist_email_addresses
  }
}
