resource "gitsync_values_yaml" "monitoring" {
  branch  = "main"
  path    = "values/grafana-k8s-monitoring.yaml"
  content = <<EOT
cluster:
  name: ${var.org}-${var.env}

global:
  scrapeInterval: "60s"

destinations:
  - name: grafana-cloud-metrics
    type: prometheus
    url: ${grafana_cloud_stack.stack.prometheus_remote_write_endpoint}
    auth:
      type: basic
      username: "${grafana_cloud_stack.stack.prometheus_user_id}"
      passwordFrom:
        secretKeyRef:
          name: grafana-k8s-monitoring-secret
          key: GF_CLOUD_ACCESS_POLICY_TOKEN

  - name: grafana-cloud-logs
    type: loki
    url: ${grafana_cloud_stack.stack.logs_url}/loki/api/v1/push
    auth:
      type: basic
      username: "${grafana_cloud_stack.stack.logs_user_id}"
      passwordFrom:
        secretKeyRef:
          name: grafana-k8s-monitoring-secret
          key: GF_CLOUD_ACCESS_POLICY_TOKEN

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
    url: ${grafana_cloud_stack.stack.fleet_management_url}
    auth:
      type: basic
      username: "${grafana_cloud_stack.stack.profiles_user_id}"
      passwordFrom:
        secretKeyRef:
          name: grafana-k8s-monitoring-secret
          key: GF_CLOUD_ACCESS_POLICY_TOKEN
      
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
    url: ${grafana_cloud_stack.stack.fleet_management_url}
    auth:
      type: basic
      username: "${grafana_cloud_stack.stack.profiles_user_id}"
      passwordFrom:
        secretKeyRef:
          name: grafana-k8s-monitoring-secret
          key: GF_CLOUD_ACCESS_POLICY_TOKEN

alloy-singleton:
  enabled: false

alloy-receiver:
  enabled: false
EOT
}
