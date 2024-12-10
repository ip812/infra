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

variable "vm_ssh_public_key" {
  type      = string
  sensitive = true
}

variable "region" {
  type = string
}

variable "az_a" {
  type = string
}

variable "az_b" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_a_cidr" {
  type = string
}

variable "public_subnet_b_cidr" {
  type = string
}

variable "organization" {
  type = string
}

variable "env" {
  type = string
}

variable "pratifeedback_domain" {
  type = string
}
