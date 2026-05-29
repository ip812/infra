locals {
  org = "ip812"
  env = "prod"

  aws_region   = "eu-central-1"
  aws_az_a     = "eu-central-1a"
  aws_az_b     = "eu-central-1b"
  aws_vpc_cidr = "10.0.0.0/16"

  cf_shoot_work_01_tunnel_name = "ip812_shoot_work_01_tunnel"
  cf_shoot_o11y_01_tunnel_name = "ip812_shoot_o11y_01_tunnel"
  gh_username                  = "iypetrov"

  blog_app_name        = "blog"
  blog_domain          = "blog"
  blog_db_name         = "blog"
  family_drive_name    = "family-drive"
  family_drive_domain  = "familydrive"
  pgadmin_domain       = "pgadmin"

  default_tags = {
    Organization = local.org
    Environment  = local.env
  }
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}

variable "cf_api_token" {
  type      = string
  sensitive = true
}

variable "cf_account_id" {
  type      = string
  sensitive = true
}

variable "cf_ip812_zone_id" {
  type      = string
  sensitive = true
}

variable "gh_access_token" {
  type      = string
  sensitive = true
}

# openssl rand -base64 64 | tr -d '\n'
variable "cf_tunnel_secret" {
  type      = string
  sensitive = true
}

variable "ts_tailnet" {
  type      = string
  sensitive = true
}

variable "ts_oauth_client_id" {
  type      = string
  sensitive = true
}

variable "ts_oauth_client_secret" {
  type      = string
  sensitive = true
}

variable "pgadmin_email" {
  type      = string
  sensitive = true
}

variable "pgadmin_password" {
  type      = string
  sensitive = true
}

variable "pg_username" {
  type      = string
  sensitive = true
}

variable "pg_password" {
  type      = string
  sensitive = true
}

variable "backups_access_key_id" {
  type      = string
  sensitive = true
}

variable "backups_secret_access_key" {
  type      = string
  sensitive = true
}

variable "dp_token" {
  type      = string
  sensitive = true
}

variable "fd_email_1" {
  type      = string
  sensitive = true
}

variable "fd_email_2" {
  type      = string
  sensitive = true
}
