variable "org" {
  type = string
}

output "org" {
  value = var.org
}

variable "env" {
  type = string
}

variable "dsc_deployments_webhook_url" {
  type      = string
  sensitive = true
}

output "dsc_deployments_webhook_url" {
  value     = var.dsc_deployments_webhook_url
  sensitive = true
}

variable "slk_bot_token" {
  type      = string
  sensitive = true
}

output "slk_bot_token" {
  value     = var.slk_bot_token
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
