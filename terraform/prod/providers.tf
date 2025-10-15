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
      source = "ip812/gitsync"
      version = "1.0.0"
    }
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = local.aws_region
}

provider "awscc" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = local.aws_region
}

provider "cloudflare" {
  api_token = var.cf_api_token
}

provider "github" {
  token = var.gh_access_token
  owner = local.org
}

provider "grafana" {
  cloud_access_policy_token = var.gf_cloud_access_policy_token
}

provider "doppler" {
  doppler_token = var.dp_token
}

provider "gitsync" {
  url   = "https://github.com/ip812/apps.git"
  token = var.gh_access_token
}
