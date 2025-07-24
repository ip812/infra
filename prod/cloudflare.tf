resource "cloudflare_zero_trust_tunnel_cloudflared" "cf_tunnel" {
  account_id    = var.cf_account_id
  name          = var.cf_tunnel_name
  config_src    = "cloudflare"
  tunnel_secret = var.cf_tunnel_secret
}

output "cf_tunnel_id" {
  value = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
}

resource "cloudflare_dns_record" "blog_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = var.blog_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.name
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

output "blog_hostname" {
  value = cloudflare_dns_record.blog_dns_record.name
}

resource "cloudflare_dns_record" "go_template_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = var.go_template_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.name
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

output "go_template_hostname" {
  value = cloudflare_dns_record.go_template_dns_record.name
}
