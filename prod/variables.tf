################################################################################
#                                  Variables                                   #
################################################################################

variable "org" {
  type = string
}

output "org" {
  value = var.org
}

variable "env" {
  type = string
}

variable "discord_deployments_webhook_url" {
  type      = string
  sensitive = true
}

output "discord_deployments_webhook_url" {
  value     = var.discord_deployments_webhook_url
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
