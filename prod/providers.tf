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

variable "hcp_client_id" {
  type      = string
  sensitive = true
}

output "hcp_client_id" {
  value     = var.hcp_client_id
  sensitive = true
}

variable "hcp_client_secret" {
  type      = string
  sensitive = true
}

output "hcp_client_secret" {
  value     = var.hcp_client_secret
  sensitive = true
}

variable "hcp_project_id" {
  type      = string
  sensitive = true
}

output "hcp_project_id" {
  value     = var.hcp_project_id
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
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.104.0"
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

provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
  project_id    = var.hcp_project_id
}
