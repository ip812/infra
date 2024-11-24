variable "organization" {
  type = string
}

variable "region" {
  type = string
}

variable "az_primary" {
  type = string
}

variable "az_secondary" {
  type = string
}

variable "env" {
  type = string
}

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

variable "pratifeedback_domain" {
  type = string
}
