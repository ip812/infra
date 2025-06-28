resource "grafana_cloud_provider_aws_account" "aws_acc" {
  stack_id = data.terraform_remote_state.prod.outputs.gf_cloud_stack_id
  role_arn = data.terraform_remote_state.prod.outputs.gf_labs_cloudwatch_integration_role_arn
  regions  = [data.terraform_remote_state.prod.outputs.aws_region]
}
