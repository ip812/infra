
variable "slk_blog_bot_token" {
  type      = string
  sensitive = true
}

locals {
  org = "ip812"
  env = "prod"
  
  aws_region   = "eu-central-1"
  aws_az_a     = "eu-central-1a"
  aws_az_b     = "eu-central-1b"
  aws_vpc_cidr = "10.0.0.0/16"

  cf_tunnel_name         = "ip812_tunnel"
  gf_aws_account_id      = "008923505280"
  gf_region_slug         = "prod-eu-west-2"
  gh_username            = "iypetrov"
  slk_general_channel_id = "C08KHNSSK5M"
  ts_tailnet             = "ilia.yavorov.petrov@gmail.com"
  
  blog_app_name = "go-template"
  blog_domain         = "blog"
  blog_db_name        = "blog"
  go_template_app_name = "go-template"
  go_template_domain  = "template"
  go_template_db_name = "template"
  pgadmin_domain      = "pgadmin"
  
  default_tags = {
    Organization = local.org
    Environment  = local.env
  }
}

variable "whitelist_email_addresses" {
  default = [
    "ilia.yavorov.petrov@gmail.com",
  ]
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

output "aws_region" {
  value = local.aws_region
}

variable "cf_api_token" {
  type      = string
  sensitive = true
}

output "cf_api_token" {
  value     = var.cf_api_token
  sensitive = true
}

variable "cf_account_id" {
  type      = string
  sensitive = true
}

output "cf_account_id" {
  value     = var.cf_account_id
  sensitive = true
}

variable "cf_ip812_zone_id" {
  type      = string
  sensitive = true
}

output "gh_username" {
  value     = local.gh_username
  sensitive = true
}

variable "gh_access_token" {
  type      = string
  sensitive = true
}

output "gh_access_token" {
  value     = var.gh_access_token
  sensitive = true
}

variable "gf_cloud_access_policy_token" {
  type      = string
  sensitive = true
}

# openssl rand -base64 64 | tr -d '\n'
variable "cf_tunnel_secret" {
  type      = string
  sensitive = true
}

variable "ts_auth_key" {
  type      = string
  sensitive = true
}

variable "ts_auth_key_ci_cd" {
  type      = string
  sensitive = true
}

variable "ts_client_id" {
  type      = string
  sensitive = true
}

variable "ts_client_secret" {
  type      = string
  sensitive = true
}

variable "ts_api_key" {
  type = string
  sensitive = true
}

output "gf_region_slug" {
  value = local.gf_region_slug
}


variable "pgadmin_email" {
  type      = string
  sensitive = true
}

output "pgadmin_email" {
  value     = var.pgadmin_email
  sensitive = true
}

variable "pgadmin_password" {
  type      = string
  sensitive = true
}

output "pgadmin_password" {
  value     = var.pgadmin_password
  sensitive = true
}

variable "pg_username" {
  type      = string
  sensitive = true
}

output "pg_username" {
  value     = var.pg_username
  sensitive = true
}

variable "pg_password" {
  type      = string
  sensitive = true
}

output "pg_password" {
  value     = var.pg_password
  sensitive = true
}

output "go_template_db_name" {
  value = local.go_template_db_name
}

output "blog_db_name" {
  value = local.blog_db_name
}

variable "dp_token" {
  type      = string
  sensitive = true
}
