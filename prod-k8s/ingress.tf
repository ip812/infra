resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
  account_id = data.terraform_remote_state.prod.outputs.cf_account_id
  tunnel_id  = data.terraform_remote_state.prod.outputs.cf_tunnel_id
  config {
    ingress_rule {
      hostname = data.terraform_remote_state.prod.outputs.pgadmin_hostname
      service  = "http://pgadmin-svc.ip812.svc.cluster.local:8080"
    }
    ingress_rule {
      hostname = data.terraform_remote_state.prod.outputs.go_template_hostname
      service  = "http://go-template-svc.ip812.svc.cluster.local:8080"
    }
    ingress_rule {
      hostname = data.terraform_remote_state.prod.outputs.blog_hostname
      service  = "http://go-template-svc.ip812.svc.cluster.local:8080"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

