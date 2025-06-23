variable "org" {
  type = string
}

variable "env" {
  type = string
}

variable "slk_github_bot_token" {
  type      = string
  sensitive = true
}

variable "slk_aws_channel_id" {
  type      = string
  sensitive = true
}

variable "slk_k8s_channel_id" {
  type      = string
  sensitive = true
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

variable "gh_username" {
  type      = string
  sensitive = true
}

variable "gh_access_token" {
  type      = string
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

variable "aws_public_subnet_a_cidr" {
  type = string
}

variable "aws_public_subnet_b_cidr" {
  type = string
}

variable "aws_private_subnet_a_cidr" {
  type = string
}

variable "aws_private_subnet_b_cidr" {
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

variable "gf_region_slug" {
  type = string
}

variable "gf_aws_account_id" {
  type = string
}

variable "pgadmin_domain" {
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

variable "go_template_domain" {
  type = string
}

variable "go_template_db_name" {
  type      = string
  sensitive = true
}
