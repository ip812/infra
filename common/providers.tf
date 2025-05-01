################################################################################
#                                  Workspaces                                  #
################################################################################

data "terraform_remote_state" "prod" {
  backend = "remote"
  config = {
    organization = "ip812"
    workspaces = {
      name = "prod"
    }
  }
}

################################################################################
#                                  Providers                                   #
################################################################################

terraform {
  backend "remote" {
    organization = "ip812"
    workspaces {
      name = "common"
    }
  }

  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.104.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.77.0"
    }
    github = {
      source  = "integrations/github"
      version = "6.4.0"
    }
  }
}

provider "hcp" {
  client_id     = data.terraform_remote_state.prod.outputs.hcp_client_id
  client_secret = data.terraform_remote_state.prod.outputs.hcp_client_secret
  project_id    = data.terraform_remote_state.prod.outputs.hcp_project_id
}

provider "aws" {
  region     = data.terraform_remote_state.prod.outputs.aws_region
  access_key = data.terraform_remote_state.prod.outputs.aws_access_key
  secret_key = data.terraform_remote_state.prod.outputs.aws_secret_key
}

provider "github" {
  token = data.terraform_remote_state.prod.outputs.gh_access_token
  owner = data.terraform_remote_state.prod.outputs.org
}
