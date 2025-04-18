variable "org" {
  type = string
}

output "org" {
  value = var.org
}

variable "env" {
  type = string
}

variable "slk_github_bot_token" {
  type      = string
  sensitive = true
}

output "slk_github_bot_token" {
  value     = var.slk_github_bot_token
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
