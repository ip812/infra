resource "grafana_cloud_provider_aws_account" "aws_acc" {
  stack_id = data.terraform_remote_state.prod.outputs.gf_cloud_stack_id
  role_arn = data.terraform_remote_state.prod.outputs.gf_labs_cloudwatch_integration_role_arn
  regions  = [data.terraform_remote_state.prod.outputs.aws_region]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "grafana_k8s_monitoring" {
  name       = "grafana-k8s-monitoring"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "k8s-monitoring"
  version    = "2.1.4"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  values = [
    <<EOF
cluster:
  name: ${var.org}
global:
  scrapeInterval: "600s"
clusterMetrics:
  enabled: false
clusterEvents:
  enabled: false
podLogs:
  enabled: true
EOF
  ]
}
