resource "cloudflare_zone" "pratifeedback_zone" {
  name = var.pratifeedback_domain
  account = {
    id = var.cloudflare_account_id
  }
}

resource "cloudflare_dns_record" "pratifeedback_dns_record" {
  zone_id = cloudflare_zone.pratifeedback_zone.id
  name    = var.pratifeedback_domain
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}
