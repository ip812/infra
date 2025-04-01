resource "hcp_vault_secrets_secret" "prod_aws_credentials" {
  app_name     = var.env_prod
  secret_name  = "aws-credentials"
  secret_value = jsonencode({
    access_key = data.terraform_remote_state.prod.outputs.aws_access_key
    secret_key = data.terraform_remote_state.prod.outputs.aws_secret_key
    region     = data.terraform_remote_state.prod.outputs.aws_region
  })
}

resource "hcp_vault_secrets_secret" "prod_pg_credentials" {
  app_name     = var.env_prod
  secret_name  = "pg-credentials"
  secret_value = jsonencode({
    pg_endpoint = data.terraform_remote_state.prod.outputs.pg_endpoint
    pg_username = data.terraform_remote_state.prod.outputs.pg_username
    pg_password = data.terraform_remote_state.prod.outputs.pg_password
  })
}
