################################################################################
#                                   Variables                                  #
################################################################################

variable "tunnel_name" {
  type      = string
  sensitive = true
}

# $ openssl rand -base64 64
variable "tunnel_secret" {
  type      = string
  sensitive = true
}

################################################################################
#                                   Tunnels                                    #
################################################################################

resource "cloudflare_zero_trust_tunnel_cloudflared" "tunnel" {
  account_id = var.cloudflare_account_id
  name       = var.tunnel_name
  secret     = var.tunnel_secret
}

output "tunnel_token" {
  value     = cloudflare_zero_trust_tunnel_cloudflared.tunnel.tunnel_token
  sensitive = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "tunnel_cfg" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.tunnel.id
  config {
    ingress_rule {
      hostname = cloudflare_record.traefik_dns_record.hostname
      service  = "http://traefik:80"
    }
    ingress_rule {
      hostname = cloudflare_record.pgadmin_dns_record.hostname
      service  = "http://traefik:80"
    }
    ingress_rule {
      hostname = cloudflare_record.go_template_dns_record.hostname
      service  = "http://traefik:80"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}
