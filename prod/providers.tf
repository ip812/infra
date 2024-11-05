################################################################################
#                                   Variables                                  #
################################################################################

variable "aws_region" {
  type = string
}

output "aws_region" {
  value     = var.aws_region
  sensitive = true
}

variable "aws_access_key" {
  type      = string
  sensitive = true
}

output "aws_access_key" {
  value     = var.aws_access_key
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

output "aws_secret_key" {
  value     = var.aws_secret_key
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

variable "cloudflare_ip812_zone_id" {
  type      = string
  sensitive = true
}

variable "github_access_token" {
  type      = string
  sensitive = true
}

output "github_access_token" {
  value     = var.github_access_token
  sensitive = true
}

################################################################################
#                                  Providers                                   #
################################################################################

terraform {
  backend "remote" {
    organization = "ip812"
    workspaces {
      name = "prod"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.77.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.49.1"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
