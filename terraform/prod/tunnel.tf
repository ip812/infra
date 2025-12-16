locals {
  whitelist_emails = [
    "ilia.yavorov.petrov@gmail.com"
  ]
  config = {
    template = { 
      k8s_ns = "template", 
      k8s_svc_name = "template-svc", 
      k8s_svc_port = "8080", 
      is_protected = false 
    }
    blog = { 
      k8s_ns = "blog", 
      k8s_svc_name = "blog-svc", 
      k8s_svc_port = "8080", 
      is_protected = false 
    }
    # pgadmin = { 
    #   k8s_ns = "database", 
    #   k8s_svc_name = "pgadmin-svc", 
    #   k8s_svc_port = "8080", 
    #   is_protected = true 
    # }
    # capacitor = { 
    #   k8s_ns = "flux-system", 
    #   k8s_svc_name = "capacitor", 
    #   k8s_svc_port = "9000", 
    #   is_protected = true
    # }
  }
}

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

# resource "cloudflare_dns_record" "dns_record" {
#   zone_id = var.cf_ip812_zone_id
#   for_each = local.config
#   name    = "${each.key}.${local.org}.com" 
#   content = "${cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id}.cfargotunnel.com"
#   type    = "CNAME"
#   ttl     = 1
#   proxied = true
# }
# 
# resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
#   account_id = var.cf_account_id
#   tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
# 
#   config = {
#     ingress = concat(
#       [
#         for key, cfg in local.config : {
#           hostname = cloudflare_dns_record.dns_record[key].name
#           service  = "http://${cfg.k8s_svc_name}.${cfg.k8s_ns}.svc.cluster.local:${cfg.k8s_svc_port}"
#         }
#       ],
#       [
#         {
#           service = "http_status:404"
#         }
#       ]
#     )
#   }
# }

# resource "cloudflare_dns_record" "blog_dns_record" {
#   zone_id = var.cf_ip812_zone_id
#   name    = "${local.blog_domain}.${local.org}.com"
#   content = "${cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id}.cfargotunnel.com"
#   type    = "CNAME"
#   ttl     = 1
#   proxied = true
# }
# 
# resource "cloudflare_dns_record" "go_template_dns_record" {
#   zone_id = var.cf_ip812_zone_id
#   name    = "${local.go_template_domain}.${local.org}.com"
#   content = "${cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id}.cfargotunnel.com"
#   type    = "CNAME"
#   ttl     = 1
#   proxied = true
# }
# 
# resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
#   account_id = var.cf_account_id
#   tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id
#   config = {
#     ingress = [
#       {
#         hostname = cloudflare_dns_record.go_template_dns_record.name
#         service  = "http://${local.go_template_app_name}-svc.${local.go_template_app_name}.svc.cluster.local:8080"
#       },
#       {
#         hostname = cloudflare_dns_record.blog_dns_record.name
#         service  = "http://${local.blog_app_name}-svc.${local.blog_app_name}.svc.cluster.local:8080"
#       },
#       {
#         service = "http_status:404"
#       }
#     ]
#   }
# }
