resource "cloudflare_zone" "pratifeedback_zone" {
  account_id = var.cloudflare_account_id
  zone       = var.pratifeedback_domain
}

resource "cloudflare_record" "pratifeedback_a_record" {
  zone_id = cloudflare_zone.pratifeedback_zone.id
  name    = "www"
  type    = "A"
  content = aws_eip.eip.public_ip
  proxied = true

  tags = {
    Domain       = var.pratifeedback_domain
    Organization = var.organization
    Environment  = var.env
    CreatedAt    = timestamp()
  }
}
