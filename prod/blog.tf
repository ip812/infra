# This file contains all resources related to the blog app

#################################################################################
#                                   Variables                                   #
#################################################################################

variable "blog_domain" {
  type      = string
  sensitive = true
}

variable "blog_port" {
  type      = string
  sensitive = true
}

variable "blog_db_file" {
  type      = string
  sensitive = true
}

#################################################################################
#                                      DNS                                      #
#################################################################################

resource "cloudflare_record" "blog_dns_record" {
  zone_id = var.cloudflare_blog_zone_id
  name    = var.blog_domain
  content = cloudflare_zero_trust_tunnel_cloudflared.ip812_tunnel.cname
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

#################################################################################
#                                      ECR                                      #
#################################################################################

resource "aws_ecr_repository" "blog_ecr_repository" {
  name                 = "${var.organization}/blog"
  image_tag_mutability = "MUTABLE"
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

