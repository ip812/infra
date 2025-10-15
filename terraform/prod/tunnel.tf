resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
  config = {
    ingress = [
      {
        hostname = cloudflare_dns_record.go_template_dns_record.name
        service  = "http://${local.go_template_app_name}-svc.${local.go_template_app_name}.svc.cluster.local:8080"
      },
      {
        hostname = cloudflare_dns_record.blog_dns_record.name
        service  = "http://${local.blog_app_name}-svc.${local.blog_app_name}.svc.cluster.local:8080"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}
