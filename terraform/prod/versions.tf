terraform {
  backend "s3" {
    bucket                      = "ip812-tf-state-bucket"
    key                         = "terraform.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints                   = { s3 = "https://cb54b3c79e547fe9cbcc0456f67c7bbf.r2.cloudflarestorage.com" }
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
