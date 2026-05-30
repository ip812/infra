locals {
  github_variables = {
    infra_ORG = {
      repository    = "infra"
      variable_name = "ORG"
      value         = local.org
    }
  }

  github_secrets = {
    lambdas_AWS_ACCESS_KEY_ID = {
      repository  = "lambdas"
      secret_name = "AWS_ACCESS_KEY_ID"
      value       = var.aws_access_key_id
    }
    lambdas_AWS_SECRET_ACCESS_KEY = {
      repository  = "lambdas"
      secret_name = "AWS_SECRET_ACCESS_KEY"
      value       = var.aws_secret_access_key
    }
    lambdas_AWS_REGION = {
      repository  = "lambdas"
      secret_name = "AWS_REGION"
      value       = local.aws_region
    }
    lambdas_GH_ACCESS_TOKEN = {
      repository  = "lambdas"
      secret_name = "GH_ACCESS_TOKEN"
      value       = var.gh_access_token
    }
    go-template_GH_ACCESS_TOKEN = {
      repository  = "go-template"
      secret_name = "GH_ACCESS_TOKEN"
      value       = var.gh_access_token
    }
    blog_GH_ACCESS_TOKEN = {
      repository  = "blog"
      secret_name = "GH_ACCESS_TOKEN"
      value       = var.gh_access_token
    }
  }
}

resource "github_actions_variable" "this" {
  for_each      = local.github_variables
  repository    = each.value.repository
  variable_name = each.value.variable_name
  value         = each.value.value
}

resource "github_actions_secret" "this" {
  for_each    = local.github_secrets
  repository  = each.value.repository
  secret_name = each.value.secret_name
  value       = each.value.value
}
