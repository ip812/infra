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
      version = "5.7.1"
    }
    github = {
      source  = "integrations/github"
      version = "6.4.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "3.22.3"
    }
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.20.0"
    }
    gitsync = {
      source  = "ip812/gitsync"
      version = "1.0.0"
    }
  }
}

