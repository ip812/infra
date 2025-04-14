################################################################################
#                                   Variables                                  #
################################################################################

variable "go_template_domain" {
  type = string
}

variable "go_template_db_name" {
  type      = string
  sensitive = true
}

output "go_template_db_name" {
  value     = var.go_template_db_name
  sensitive = true
}

################################################################################
#                                     DNS                                      #
################################################################################

resource "cloudflare_record" "go_template_dns_record" {
  zone_id = var.cf_ip812_zone_id
  name    = var.go_template_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.cf_tunnel.cname
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
    query         = "CREATE DATABASE \"${var.go_template_db_name}\";",
  })
  triggers = {
    redeployment = sha1(jsonencode([
      aws_db_instance.pg.id
    ]))
  }
}
