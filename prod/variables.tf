# This file contains all common variables that are used in the project

################################################################################
#                                  Variables                                   #
################################################################################

variable "aws_account_id" {
  type      = string
  sensitive = true
}

variable "organization" {
  type = string
}

variable "env" {
  type = string
}

variable "whitelist_email_addresses" {
  default = [
    "ilia.yavorov.petrov@gmail.com",
  ]
}

