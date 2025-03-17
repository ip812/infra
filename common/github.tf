################################################################################
#                                   Secrets                                    #
################################################################################

# Infra
resource "github_actions_variable" "infra_org" {
  repository    = "infra"
  variable_name = "ORG"
  value         = data.terraform_remote_state.prod.outputs.org
}

resource "github_actions_secret" "infra_github_access_token" {
  repository      = "infra"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = data.terraform_remote_state.prod.outputs.github_access_token
}

resource "github_actions_secret" "infra_discord_deployments_webhook_url" {
  repository      = "infra"
  secret_name     = "DISCORD_DEPLOYMENTS_WEBHOOK_URL"
  plaintext_value = data.terraform_remote_state.prod.outputs.discord_deployments_webhook_url
}

# Apps
resource "github_actions_variable" "apps_org" {
  repository    = "apps"
  variable_name = "ORG"
  value         = data.terraform_remote_state.prod.outputs.org
}

resource "github_actions_secret" "apps_aws_region" {
  repository      = "apps"
  secret_name     = "AWS_REGION"
  plaintext_value = data.terraform_remote_state.prod.outputs.aws_region
}

resource "github_actions_secret" "apps_aws_access_key" {
  repository      = "apps"
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = data.terraform_remote_state.prod.outputs.aws_access_key
}

resource "github_actions_secret" "apps_aws_secret_key" {
  repository      = "apps"
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = data.terraform_remote_state.prod.outputs.aws_secret_key
}

resource "github_actions_secret" "apps_github_access_token" {
  repository      = "apps"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = data.terraform_remote_state.prod.outputs.github_access_token
}

resource "github_actions_secret" "apps_discord_deployments_webhook_url" {
  repository      = "apps"
  secret_name     = "DISCORD_DEPLOYMENTS_WEBHOOK_URL"
  plaintext_value = data.terraform_remote_state.prod.outputs.discord_deployments_webhook_url
}

# lambdas
resource "github_actions_secret" "lambdas_aws_access_key" {
  repository      = "lambdas"
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = data.terraform_remote_state.prod.outputs.aws_access_key
}

resource "github_actions_secret" "lambdas_aws_secret_key" {
  repository      = "lambdas"
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = data.terraform_remote_state.prod.outputs.aws_secret_key
}

resource "github_actions_secret" "lambdas_aws_region" {
  repository      = "lambdas"
  secret_name     = "AWS_REGION"
  plaintext_value = data.terraform_remote_state.prod.outputs.aws_region
}

resource "github_actions_secret" "lambdas_github_access_token" {
  repository      = "lambdas"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = data.terraform_remote_state.prod.outputs.github_access_token
}

# go-template
resource "github_actions_secret" "go_template_aws_access_key" {
  repository      = "go-template"
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = data.terraform_remote_state.prod.outputs.aws_access_key
}

resource "github_actions_secret" "go_template_aws_secret_key" {
  repository      = "go-template"
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = data.terraform_remote_state.prod.outputs.aws_secret_key
}

resource "github_actions_secret" "go_template_aws_region" {
  repository      = "go-template"
  secret_name     = "AWS_REGION"
  plaintext_value = data.terraform_remote_state.prod.outputs.aws_region
}

resource "github_actions_secret" "go_template_github_access_token" {
  repository      = "go-template"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = data.terraform_remote_state.prod.outputs.github_access_token
}
