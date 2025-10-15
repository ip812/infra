resource "cloudflare_zero_trust_tunnel_cloudflared" "cf_tunnel" {
  account_id    = var.cf_account_id
  name          = local.cf_tunnel_name
  config_src    = "cloudflare"
  tunnel_secret = var.cf_tunnel_secret
}

data "cloudflare_zero_trust_tunnel_cloudflared_token" "cf_tunnel_token" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
}

resource "cloudflare_dns_record" "blog_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = "${local.blog_domain}.${local.org}.com"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "go_template_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = "${local.go_template_domain}.${local.org}.com"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}
