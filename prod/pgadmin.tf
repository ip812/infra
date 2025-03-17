################################################################################
#                                 Variables                                    #
################################################################################

variable "pgadmin_domain" {
  type      = string
  sensitive = true
}

################################################################################
#                                     DNS                                      #
################################################################################

resource "cloudflare_record" "pgadmin_dns_record" {
  zone_id = var.cloudflare_ip812_zone_id
  name    = var.pgadmin_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_zero_trust_access_application" "pgadmin_zt_app" {
  zone_id                   = var.cloudflare_ip812_zone_id
  name                      = "pgadmin"
  domain                    = "pgadmin.${var.org}.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_zero_trust_access_policy" "pgadmin_ap" {
  zone_id        = var.cloudflare_ip812_zone_id
  application_id = cloudflare_zero_trust_access_application.pgadmin_zt_app.id
  name           = "pgadmin"
  decision       = "allow"
  precedence     = 1
  include {
    email = var.whitelist_email_addresses
  }
}
