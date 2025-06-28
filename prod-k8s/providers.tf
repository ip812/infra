data "terraform_remote_state" "prod" {
  backend = "remote"
  config = {
    organization = "ip812"
    workspaces = {
      name = "prod"
    }
  }
}

terraform {
  backend "remote" {
    organization = "ip812"
    workspaces {
      name = "prod-k8s"
    }
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.37.1"
    }
    grafana = {
      source  = "grafana/grafana"
      version = "3.22.3"
    }
  }
}

provider "kubernetes" {
  host                   = var.k8s_host
  client_certificate     = base64decode(var.k8s_client_certificate)
  client_key             = base64decode(var.k8s_client_key)
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
}


provider "aws" {
  region     = data.terraform_remote_state.prod.outputs.aws_region
  access_key = data.terraform_remote_state.prod.outputs.aws_access_key
  secret_key = data.terraform_remote_state.prod.outputs.aws_secret_key
}

provider "grafana" {
  cloud_provider_access_token = data.terraform_remote_state.prod.outputs.gf_cloud_provider_access_token
  cloud_provider_url          = "https://cloud-provider-api-${data.terraform_remote_state.prod.outputs.gf_region_slug}.grafana.net"
}
