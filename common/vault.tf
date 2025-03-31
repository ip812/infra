resource "hcp_vault_secrets_secret" "prod_aws_access_key" {
  app_name     = var.env_prod 
  secret_name  = "aws_access_key"
  secret_value = data.terraform_remote_state.prod.outputs.aws_access_key
}
