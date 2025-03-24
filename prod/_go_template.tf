################################################################################
#                                   Variables                                  #
################################################################################

variable "go_template_domain" {
  type = string
}

variable "go_template_port" {
  type = string
}

variable "go_template_db_name" {
  type      = string
  sensitive = true
}

variable "go_template_db_ssl_mode" {
  type      = string
  sensitive = true
}

################################################################################
#                                     DNS                                      #
################################################################################

resource "cloudflare_record" "go_template_dns_record" {
  zone_id = var.cloudflare_ip812_zone_id
  name    = var.go_template_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

################################################################################
#                                     APP                                      #
################################################################################

resource "aws_lambda_invocation" "create_go_template_db" {
  function_name = aws_lambda_function.pg_query_exec_function.function_name
  input = jsonencode({
    database_name = "postgres",
    query         = "CREATE DATABASE ${var.go_template_db_name};",
    ssl_mode      = var.go_template_db_ssl_mode,
  })
  triggers = {
    redeployment = sha1(jsonencode([
      aws_db_instance.db.id
    ]))
  }
}
