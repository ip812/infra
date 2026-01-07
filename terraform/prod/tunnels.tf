locals {
  tunnel_config = {
    template = {
      k8s_ns       = "go-template",
      k8s_svc_name = "go-template-svc",
      k8s_svc_port = "8080",
      is_protected = false
    }
    blog = {
      k8s_ns       = "blog",
      k8s_svc_name = "blog-svc",
      k8s_svc_port = "8080",
      is_protected = false
    }
    pgadmin = {
      k8s_ns       = "postgres",
      k8s_svc_name = "pgadmin-svc",
      k8s_svc_port = "8080",
      is_protected = true
    }
    capacitor = {
      k8s_ns       = "capacitor",
      k8s_svc_name = "capacitor",
      k8s_svc_port = "9000",
      is_protected = true
    }
    prometheus = {
      k8s_ns       = "monitoring",
      k8s_svc_name = "prometheus-stack-kube-prom-prometheus",
      k8s_svc_port = "9090",
      is_protected = true
    }
    # alertmanager = {
    #   k8s_ns       = "monitoring",
    #   k8s_svc_name = "prometheus-stack-kube-prom-alertmanager",
    #   k8s_svc_port = "9093",
    #   is_protected = true
    # }
    grafana = {
      k8s_ns       = "monitoring",
      k8s_svc_name = "prometheus-stack-grafana",
      k8s_svc_port = "80",
      is_protected = true
    }
    # kibana = {
    #   k8s_ns       = "elasticsearch",
    #   k8s_svc_name = "kibana-kibana",
    #   k8s_svc_port = "5601",
    #   is_protected = true
    # }
    jaeger = {
      k8s_ns       = "tracing",
      k8s_svc_name = "jaeger",
      k8s_svc_port = "16686",
      is_protected = true
    }
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

resource "cloudflare_dns_record" "dns_record" {
  for_each = local.tunnel_config
  zone_id  = var.cf_ip812_zone_id
  name     = "${each.key}.${local.org}.com"
  content  = "${cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id}.cfargotunnel.com"
  type     = "CNAME"
  ttl      = 1
  proxied  = true
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
  account_id = var.cf_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.id

  config = {
    ingress = concat(
      [
        for key, cfg in local.tunnel_config : {
          hostname = cloudflare_dns_record.dns_record[key].name
          service  = "http://${cfg.k8s_svc_name}.${cfg.k8s_ns}.svc.cluster.local:${cfg.k8s_svc_port}"
        }
      ],
      [
        {
          service = "http_status:404"
        }
      ]
    )
  }
}

resource "cloudflare_zero_trust_access_policy" "zt_access_policy" {
  account_id       = var.cf_account_id
  name             = "Admin allowlist"
  decision         = "allow"
  session_duration = "8h"

  include = [
    for email in local.whitelist_emails : {
      email = {
        email = email
      }
    }
  ]
}

resource "cloudflare_zero_trust_access_application" "zt_access_application" {
  for_each = {
    for key, cfg in local.tunnel_config :
    key => cfg
    if cfg.is_protected
  }

  account_id                = var.cf_account_id
  name                      = "${each.key} ${local.org} ${local.env}"
  domain                    = "${each.key}.${local.org}.com"
  type                      = "self_hosted"
  session_duration          = "8h"
  auto_redirect_to_identity = true

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.zt_access_policy.id
      precedence = 1
    }
  ]
}
