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
