variable "org" {
  type = string
}

variable "env" {
  type = string
}

variable "slk_blog_bot_token" {
  type      = string
  sensitive = true
}

variable "slk_general_channel_id" {
  type = string
}

locals {
  default_tags = {
    Organization = var.org
    Environment  = var.env
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

variable "aws_region" {
  type = string
}

output "aws_region" {
  value = var.aws_region
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

variable "gh_username" {
  type      = string
  sensitive = true
}

output "gh_username" {
  value     = var.gh_username
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

variable "aws_az_a" {
  type = string
}

variable "aws_az_b" {
  type = string
}

variable "aws_vpc_cidr" {
  type = string
}

variable "cf_tunnel_name" {
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

variable "ts_oauth_client_id" {
  type      = string
  sensitive = true
}

variable "ts_oauth_secret" {
  type      = string
  sensitive = true
}

variable "gf_region_slug" {
  type = string
}

output "gf_region_slug" {
  value = var.gf_region_slug
}

variable "gf_aws_account_id" {
  type = string
}

variable "pgadmin_domain" {
  type      = string
  sensitive = true
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

variable "go_template_domain" {
  type = string
}

variable "go_template_db_name" {
  type = string
}

output "go_template_db_name" {
  value = var.go_template_db_name
}

variable "blog_domain" {
  type = string
}

variable "blog_db_name" {
  type = string
}

output "blog_db_name" {
  value = var.blog_db_name
}

variable "dp_token" {
  type      = string
  sensitive = true
}
