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
