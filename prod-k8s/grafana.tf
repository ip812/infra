resource "grafana_cloud_provider_aws_account" "aws_acc" {
  stack_id = data.terraform_remote_state.prod.outputs.gf_cloud_stack.id
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
  name: ${var.org}-${var.env}
global:
  scrapeInterval: "600s"
destinations:
  - name: grafana-cloud-metrics
    type: prometheus
    url: ${data.terraform_remote_state.prod.outputs.gf_cloud_stack.prometheus_remote_write_endpoint}
    auth:
      type: basic
      username: "${data.terraform_remote_state.prod.outputs.gf_cloud_stack.prometheus_user_id}"
      password: ${var.gf_cloud_access_policy_token}
  - name: grafana-cloud-logs
    type: loki
    url: ${data.terraform_remote_state.prod.outputs.gf_cloud_stack.logs_url}/loki/api/v1/push
    auth:
      type: basic
      username: "${data.terraform_remote_state.prod.outputs.gf_cloud_stack.logs_user_id}"
      password: ${var.gf_cloud_access_policy_token}
clusterMetrics:
  enabled: true
clusterEvents:
  enabled: false
podLogs:
  enabled: true
applicationObservability:
  enabled: false
alloy-metrics:
  enabled: true
  alloy:
    extraEnv:
      - name: GCLOUD_RW_API_KEY
        valueFrom:
          secretKeyRef:
            name: alloy-metrics-remote-cfg-grafana-k8s-monitoring
            key: password
      - name: CLUSTER_NAME
        value: ${var.org}-${var.env}
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: GCLOUD_FM_COLLECTOR_ID
        value: grafana-k8s-monitoring-\$(CLUSTER_NAME)-\$(NAMESPACE)-\$(POD_NAME)
  remoteConfig:
    enabled: true
    url: ${data.terraform_remote_state.prod.outputs.gf_cloud_stack.fleet_management_url} 
    auth:
      type: basic
      username: ${data.terraform_remote_state.prod.outputs.gf_cloud_stack.profiles_user_id} 
      password: ${var.gf_cloud_access_policy_token}
alloy-logs:
  enabled: true
  alloy:
    extraEnv:
      - name: GCLOUD_RW_API_KEY
        valueFrom:
          secretKeyRef:
            name: alloy-logs-remote-cfg-grafana-k8s-monitoring
            key: password
      - name: CLUSTER_NAME
        value: ${var.org}-${var.env} 
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: POD_NAME
        valueFrom:
          fieldRef:
            fieldPath: metadata.name
      - name: NODE_NAME
        valueFrom:
          fieldRef:
            fieldPath: spec.nodeName
      - name: GCLOUD_FM_COLLECTOR_ID
        value: grafana-k8s-monitoring-\$(CLUSTER_NAME)-\$(NAMESPACE)-alloy-logs-\$(NODE_NAME)
  remoteConfig:
    enabled: true
    url: ${data.terraform_remote_state.prod.outputs.gf_cloud_stack.fleet_management_url} 
    auth:
      type: basic
      username: ${data.terraform_remote_state.prod.outputs.gf_cloud_stack.profiles_user_id} 
      password: ${var.gf_cloud_access_policy_token}
alloy-singleton:
  enabled: false
alloy-receiver:
  enabled: false
EOF
  ]
}
