resource "hcp_vault_secrets_secret" "prod_aws_access_key" {
  app_name     = var.env_prod
  secret_name  = "aws_access_key"
  secret_value = data.terraform_remote_state.prod.outputs.aws_access_key
}

resource "hcp_vault_secrets_secret" "prod_aws_secret_key" {
  app_name     = var.env_prod
  secret_name  = "aws_secret_key"
  secret_value = data.terraform_remote_state.prod.outputs.aws_secret_key
}

resource "hcp_vault_secrets_secret" "prod_aws_region" {
  app_name     = var.env_prod
  secret_name  = "aws_region"
  secret_value = data.terraform_remote_state.prod.outputs.aws_region
}

resource "hcp_vault_secrets_secret" "prod_cf_tunnel_token" {
  app_name     = var.env_prod
  secret_name  = "cf_tunnel_token"
  secret_value = data.terraform_remote_state.prod.outputs.cf_tunnel_token
}

resource "hcp_vault_secrets_secret" "prod_pg_endpoint" {
  app_name     = var.env_prod
  secret_name  = "pg_endpoint"
  secret_value = data.terraform_remote_state.prod.outputs.pg_endpoint
}

resource "hcp_vault_secrets_secret" "prod_pg_username" {
  app_name     = var.env_prod
  secret_name  = "pg_username"
  secret_value = data.terraform_remote_state.prod.outputs.pg_username
}

resource "hcp_vault_secrets_secret" "prod_pg_password" {
  app_name     = var.env_prod
  secret_name  = "pg_password"
  secret_value = data.terraform_remote_state.prod.outputs.pg_password
}

resource "hcp_vault_secrets_secret" "prod_go_template_pg_name" {
  app_name     = var.env_prod
  secret_name  = "go_template_pg_name"
  secret_value = data.terraform_remote_state.prod.outputs.go_template_db_name
}

