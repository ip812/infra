resource "cloudflare_dns_record" "traefik_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = "traefik"
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_access_application" "traefik_ap" {
  zone_id          = var.cloudflare_blog_zone_id
  name             = "Traefik"
  domain           = "traefik.deviliablog.com"
  session_duration = "1h"
}

resource "cloudflare_access_policy" "traefik_policy" {
  application_id = cloudflare_access_application.traefik_ap.id
  zone_id        = var.cloudflare_blog_zone_id
  name           = "Traefik Access Policy"
  precedence     = 1
  decision       = "allow"

  include {
    emails = ["ilia.yavorov.petrov@gmail.com"]
  }
}

resource "cloudflare_dns_record" "portainer_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = "portainer"
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_access_application" "portainer_ap" {
  zone_id          = var.cloudflare_blog_zone_id
  name             = "Portainer"
  domain           = "portainer.deviliablog.com"
  session_duration = "1h"
}

resource "cloudflare_access_policy" "portainer_policy" {
  application_id = cloudflare_access_application.portainer_ap.id
  zone_id        = var.cloudflare_blog_zone_id
  name           = "Portainer Access Policy"
  precedence     = 1
  decision       = "allow"

  include {
    emails = ["ilia.yavorov.petrov@gmail.com"]
  }
}

resource "cloudflare_dns_record" "blog_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = var.blog_domain
  content = aws_eip.eip.public_ip
  type    = "A"
  ttl     = 1
  proxied = true
}
