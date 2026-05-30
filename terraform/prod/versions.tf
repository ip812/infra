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
      version = "6.47.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.1"
    }
    github = {
      source  = "integrations/github"
      version = "6.12.1"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.21.2"
    }
  }
}
