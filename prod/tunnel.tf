# This file contains all resources related to the Cloudflare tunnels

#################################################################################
#                                    Tunnels                                    #
#################################################################################

variable "ip812_tunnel_secret" {
  type      = string
  sensitive = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "ip812_tunnel" {
  account_id = var.cloudflare_account_id
  name       = "ip812_tunnel"
  secret     = var.ip812_tunnel_secret
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
      hostname = cloudflare_record.blog_dns_record.hostname
      service  = "http://traefik:80"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

