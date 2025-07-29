resource "grafana_cloud_provider_aws_account" "aws_acc" {
  stack_id = data.terraform_remote_state.prod.outputs.gf_cloud_stack.id
  role_arn = data.terraform_remote_state.prod.outputs.gf_labs_cloudwatch_integration_role_arn
  regions  = [data.terraform_remote_state.prod.outputs.aws_region]
}

locals {
  monitoring_values_yaml = sensitive(templatefile("${path.module}/values/grafana-k8s-monitoring.values.yaml.tmpl", {
    org                          = var.org
    env                          = var.env
    prometheus_remote_write_url  = data.terraform_remote_state.prod.outputs.gf_cloud_stack.prometheus_remote_write_endpoint
    prometheus_user_id           = data.terraform_remote_state.prod.outputs.gf_cloud_stack.prometheus_user_id
    logs_url                     = data.terraform_remote_state.prod.outputs.gf_cloud_stack.logs_url
    logs_user_id                 = data.terraform_remote_state.prod.outputs.gf_cloud_stack.logs_user_id
    gf_cloud_access_policy_token = var.gf_cloud_access_policy_token
    fleet_management_url         = data.terraform_remote_state.prod.outputs.gf_cloud_stack.fleet_management_url
    profiles_user_id             = data.terraform_remote_state.prod.outputs.gf_cloud_stack.profiles_user_id
  }))
}

resource "helm_release" "grafana_k8s_monitoring" {
  name             = "grafana-k8s-monitoring"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "k8s-monitoring"
  version          = "3.1.0"
  namespace        = "monitoring"
  create_namespace = true
  wait             = false
  timeout          = 600
  values          = [local.monitoring_values_yaml]
}
