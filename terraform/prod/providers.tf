provider "aws" {
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

provider "doppler" {
  doppler_token = var.dp_token
}

provider "proxmox" {
  endpoint  = "https://proxmox.wireguard.${local.org}.com:8006/"
  api_token = "${var.pm_api_token_id}=${var.pm_api_token_secret}"
  insecure  = true

  ssh {
    agent    = false
    username = "root"
  }
}
