variable "org" {
  type = string
}

output "org" {
  value = var.org
}

variable "env" {
  type = string
}

variable "slk_argocd_bot_token" {
  type      = string
  sensitive = true
}

variable "slk_github_bot_token" {
  type      = string
  sensitive = true
}

output "slk_github_bot_token" {
  value     = var.slk_github_bot_token
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
