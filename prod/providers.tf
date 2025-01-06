terraform {
  backend "remote" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.77.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.49.1"
    }
    github = {
      source  = "integrations/github"
      version = "6.4.0"
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

provider "github" {
  token = var.github_access_token
  owner = var.organization
}
