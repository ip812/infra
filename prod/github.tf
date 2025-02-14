# This file contains all needed secrets for the CI/CD pipeline

################################################################################
#                                   Variables                                  #
################################################################################

variable "discord_deployments_webhook_url" {
  type      = string
  sensitive = true
}

################################################################################
#                                   Secrets                                    #
################################################################################

# Infra
# This secret has to be added manulay, so the CI/CD pipeline to be able to create the infrastructure from scratch.
# resource "github_actions_secret" "infr_terrafrom_api_token" {
#  repository      = "infra"
#  secret_name     = "TF_API_TOKEN"
#  plaintext_value = var.terraform_api_token
# }

resource "github_actions_secret" "apps_org" {
  repository      = "infra"
  secret_name     = "ORG"
  plaintext_value = var.organization
}

# Apps
resource "github_actions_secret" "apps_org" {
  repository      = "apps"
  secret_name     = "ORG"
  plaintext_value = var.organization
}

resource "github_actions_secret" "apps_aws_account_id" {
  repository      = "apps"
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_secret" "apps_aws_access_key" {
  repository      = "apps"
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key
}

resource "github_actions_secret" "apps_aws_secret_key" {
  repository      = "apps"
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_key
}

resource "github_actions_secret" "apps_github_access_token" {
  repository      = "apps"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = var.github_access_token
}

resource "github_actions_secret" "apps_ip812_tunnel_token" {
  repository      = "apps"
  secret_name     = "CF_TUNNEL_TOKEN"
  plaintext_value = cloudflare_zero_trust_tunnel_cloudflared.ip812_tunnel.tunnel_token
}

resource "github_actions_secret" "apps_discord_deployments_webhook_url" {
  repository      = "apps"
  secret_name     = "DISCORD_DEPLOYMENTS_WEBHOOK_URL"
  plaintext_value = var.discord_deployments_webhook_url
}

# Blog
resource "github_actions_secret" "blog_aws_access_key" {
  repository      = "blog"
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key
}

resource "github_actions_secret" "blog_aws_secret_key" {
  repository      = "blog"
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_key
}

resource "github_actions_secret" "blog_aws_account_id" {
  repository      = "blog"
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_secret" "blog_github_access_token" {
  repository      = "blog"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = var.github_access_token
}

