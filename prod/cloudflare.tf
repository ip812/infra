resource "cloudflare_dns_record" "blog_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = var.blog_domain
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "blog_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = "traefik"
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "blog_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = "portainer"
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}
