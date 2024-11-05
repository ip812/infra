################################################################################
#                                   Variables                                  #
################################################################################

variable "go_template_domain" {
  type = string
}

variable "go_template_port" {
  type = string
}

variable "go_template_db_name" {
  type      = string
  sensitive = true
}

variable "go_template_db_port" {
  type      = string
  sensitive = true
}

variable "go_template_db_ssl" {
  type      = string
  sensitive = true
}

################################################################################
#                                     DNS                                      #
################################################################################

resource "cloudflare_record" "go_template_dns_record" {
  zone_id = var.cloudflare_ip812_zone_id
  name    = var.go_template_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
