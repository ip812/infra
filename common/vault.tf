resource "hcp_vault_secrets_secret" "prod_aws_credentials" {
  app_name     = var.env_prod
  secret_name  = "aws_credentials"
  secret_value = jsonencode({
    access_key = data.terraform_remote_state.prod.outputs.aws_access_key
    secret_key = data.terraform_remote_state.prod.outputs.aws_secret_key
    region     = data.terraform_remote_state.prod.outputs.aws_region
  })
}
