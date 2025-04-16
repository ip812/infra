################################################################################
#                                   Variables                                  #
################################################################################

variable "cf_tunnel_name" {
  type      = string
  sensitive = true
}

# openssl rand -base64 64 | tr -d '\n'
variable "cf_tunnel_secret" {
  type      = string
  sensitive = true
}

################################################################################
#                                   Tunnels                                    #
################################################################################

resource "cloudflare_zero_trust_tunnel_cloudflared" "cf_tunnel" {
  account_id = var.cf_account_id
  name       = var.cf_tunnel_name
  secret     = var.cf_tunnel_secret
}

output "cf_tunnel_token" {
  value     = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.tunnel_token
  sensitive = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
  config {
    ingress_rule {
      hostname = cloudflare_record.traefik_dns_record.hostname
      service  = "http://traefik.ip812.svc.cluster.local:8080"
    }
    ingress_rule {
      hostname = cloudflare_record.pgadmin_dns_record.hostname
      service  = "http://traefik.ip812.svc.cluster.local:8080"
    }
    ingress_rule {
      hostname = cloudflare_record.go_template_dns_record.hostname
      service  = "http://traefik.ip812.svc.cluster.local:8080"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}
