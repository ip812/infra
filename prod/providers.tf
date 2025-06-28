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
    github = {
      source  = "integrations/github"
      version = "6.4.0"
    }
    # time = {
    #   source  = "hashicorp/time"
    #   version = "0.13.1-alpha1"
    # }
    # grafana = {
    #   source  = "grafana/grafana"
    #   version = "3.22.3"
    # }
  }
}

provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

provider "awscc" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

provider "cloudflare" {
  api_token = var.cf_api_token
}

provider "github" {
  token = var.gh_access_token
  owner = var.org
}

# provider "grafana" {
#   alias                     = "cloud"
#   cloud_access_policy_token = var.gf_cloud_access_policy_token
# }
