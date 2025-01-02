variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "cloudflare_blog_zone_id" {
  type      = string
  sensitive = true
}

variable "admin_ssh_public_key" {
  type      = string
  sensitive = true
}

variable "deploy_ssh_public_key" {
  type      = string
  sensitive = true
}

variable "deploy_ssh_private_key" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type = string
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

variable "organization" {
  type = string
}

variable "env" {
  type = string
}

variable "blog_domain" {
  type = string
}

variable "github_access_token" {
  type      = string
  sensitive = true
}

variable "aws_account_id" {
  type = string
  sensitive = true
}

variable "blog_db_file" {
  type = string
  sensitive = true
}
