resource "cloudflare_record" "traefik_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = "traefik"
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "portainer_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = "portainer"
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "blog_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = var.blog_domain
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_zero_trust_access_application" "traefik_zt_app" {
  zone_id                   = var.cloudflare_blog_zone_id
  name                      = "traefik"
  domain                    = "traefik.deviliablog.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_access_policy" "traefik_ap" {
  account_id = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.traefik_zt_app.id
  name       = var.organization
  decision   = "allow"
  precedence     = 1

  include {
    email = var.whitelist_email_addresses
  }

  require {
    email = var.whitelist_email_addresses
  }
}

resource "cloudflare_zero_trust_access_application" "portainer_zt_app" {
  zone_id                   = var.cloudflare_blog_zone_id
  name                      = "portainer"
  domain                    = "portainer.deviliablog.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = true
}

resource "cloudflare_access_policy" "portainer_ap" {
  account_id = var.cloudflare_account_id
  application_id = cloudflare_zero_trust_access_application.portainer_zt_app.id
  name       = var.organization
  decision   = "allow"
  precedence     = 1

  include {
    email = var.whitelist_email_addresses
  }

  require {
    email = var.whitelist_email_addresses
  }
}
