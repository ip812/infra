resource "cloudflare_zero_trust_tunnel_cloudflared_config" "cf_tunnel_cfg" {
  account_id = data.terraform_remote_state.prod.outputs.cf_account_id
  tunnel_id  = data.terraform_remote_state.prod.outputs.cf_tunnel_id
  config = {
    ingress = [
      {
        hostname = data.terraform_remote_state.prod.outputs.go_template_hostname
        service  = "http://go-template-svc.ip812.svc.cluster.local:8080"
      },
      {
        hostname = data.terraform_remote_state.prod.outputs.blog_hostname
        service  = "http://blog-svc.ip812.svc.cluster.local:8080"
      },
      {
        service = "http_status:404"
      }
    ]
  }
}
