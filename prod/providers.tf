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

output "gh_access_token" {
  value     = var.gh_access_token
  sensitive = true
}

variable "gf_cloud_access_policy_token" {
  type      = string
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
    awscc = {
      source  = "hashicorp/awscc"
      version = "1.35.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.49.1"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.1-alpha1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "3.22.3"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

provider "awscc" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

provider "cloudflare" {
  api_token = var.cf_api_token
}

provider "grafana" {
  alias                     = "cloud"
  cloud_access_policy_token = var.gf_cloud_access_policy_token
}
