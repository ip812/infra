# This secret will be added manulay, so the CI/CD pipeline to be able to create the infrastructure from scratch.
# resource "github_actions_secret" "infr_terrafrom_api_token" {
#  repository      = "infr"
#  secret_name     = "TF_API_TOKEN"
#  plaintext_value = var.terraform_api_token
# }

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
  secret_name     = "REPO_TOKEN"
  plaintext_value = var.github_access_token
}

resource "github_actions_secret" "apps_ip812_tunnel_token" {
  repository      = "apps"
  secret_name     = "IP812_TUNNEL_TOKEN"
  plaintext_value = cloudflare_zero_trust_tunnel_cloudflared.ip812_tunnel.token
}

resource "github_actions_secret" "blog_aws_account_id" {
  repository      = "blog"
  secret_name     = "AWS_REGION"
  plaintext_value = var.aws_region
}

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

resource "github_actions_secret" "blog_github_access_token" {
  repository      = "blog"
  secret_name     = "REPO_TOKEN"
  plaintext_value = var.github_access_token
}
