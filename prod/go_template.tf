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
#                                     DB                                       #
################################################################################
resource "aws_lambda_invocation" "create_go_template_db" {
  depends_on = [
    aws_lambda_function.db_query_exec_function
  ]

  function_name = aws_lambda_function.db_query_exec_function.function_name
  input = jsonencode({
    database_name = "postgres",
    query         = "SELECT 'CREATE DATABASE \"${var.go_template_db_name}\"' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${var.go_template_db_name}');",
    ssl_mode      = var.go_template_db_ssl_mode,
  })
}
