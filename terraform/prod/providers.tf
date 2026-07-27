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
  pm_api_url = "https://proxmox.wireguard.${local.org}.com:8006/api2/json"
  pm_api_token_id = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure = true
}
