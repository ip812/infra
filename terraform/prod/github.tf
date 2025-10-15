resource "github_actions_variable" "infra_org" {
  repository    = "infra"
  variable_name = "ORG"
  value         = local.org
}

resource "github_actions_secret" "infra_github_access_token" {
  repository      = "infra"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = var.gh_access_token
}

resource "github_actions_secret" "infra_aws_access_key_id" {
  repository      = "infra"
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key_id
}

resource "github_actions_secret" "infra_aws_secret_access_key" {
  repository      = "infra"
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_access_key
}

resource "github_actions_secret" "infra_aws_region" {
  repository      = "infra"
  secret_name     = "AWS_REGION"
  plaintext_value = local.aws_region
}

resource "github_actions_secret" "infra_ts_auth_key" {
  repository      = "infra"
  secret_name     = "TS_AUTH_KEY"
  plaintext_value = var.ts_auth_key
}

resource "github_actions_secret" "infra_ts_auth_key_ci_cd" {
  repository      = "infra"
  secret_name     = "TS_AUTH_KEY_CI_CD"
  plaintext_value = var.ts_auth_key_ci_cd
}

resource "github_actions_secret" "lambdas_aws_access_key_id" {
  repository      = "lambdas"
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key_id
}

resource "github_actions_secret" "lambdas_aws_secret_access_key" {
  repository      = "lambdas"
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_access_key
}

resource "github_actions_secret" "lambdas_aws_region" {
  repository      = "lambdas"
  secret_name     = "AWS_REGION"
  plaintext_value = local.aws_region
}

resource "github_actions_secret" "lambdas_github_access_token" {
  repository      = "lambdas"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = var.gh_access_token
}

resource "github_actions_secret" "go_template_github_access_token" {
  repository      = "go-template"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = var.gh_access_token
}

resource "github_actions_secret" "blog_github_access_token" {
  repository      = "blog"
  secret_name     = "GH_ACCESS_TOKEN"
  plaintext_value = var.gh_access_token
}
