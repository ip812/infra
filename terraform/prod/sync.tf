resource "gitsync_values_yaml" "monitoring" {
  branch  = "main"
  path    = "values/grafana-k8s-monitoring.yaml"
  content = <<EOT
cluster:
  name: ${local.org}-${local.env}
global:
  scrapeInterval: "60s"
destinations:
  - name: grafana-cloud-metrics
    type: prometheus
    url: ${grafana_cloud_stack.stack.prometheus_remote_write_endpoint}
    auth:
      type: basic
      usernameKey: GF_CLOUD_PROMETHEUS_USER_ID
      passwordKey: GF_CLOUD_ACCESS_POLICY_TOKEN
    secret:
      create: false
      name: grafana-k8s-monitoring-secret

  - name: grafana-cloud-logs
    type: loki
    url: ${grafana_cloud_stack.stack.logs_url}/loki/api/v1/push
    auth:
      type: basic
      usernameKey: GF_CLOUD_LOGS_USER_ID
      passwordKey: GF_CLOUD_ACCESS_POLICY_TOKEN
    secret:
      create: false
      name: grafana-k8s-monitoring-secret
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
            name: grafana-k8s-monitoring-secret
            key: GF_CLOUD_ACCESS_POLICY_TOKEN
      - name: CLUSTER_NAME
        value: ${local.org}-${local.env}
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
      usernameKey: GF_CLOUD_PROFILES_USER_ID
      passwordKey: GF_CLOUD_ACCESS_POLICY_TOKEN
    secret:
      create: false
      name: grafana-k8s-monitoring-secret
alloy-logs:
  enabled: true
  alloy:
    extraEnv:
      - name: GCLOUD_RW_API_KEY
        valueFrom:
          secretKeyRef:
            name: grafana-k8s-monitoring-secret
            key: GF_CLOUD_ACCESS_POLICY_TOKEN
      - name: CLUSTER_NAME
        value: ${local.org}-${local.env}
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
      usernameKey: GF_CLOUD_PROFILES_USER_ID
      passwordKey: GF_CLOUD_ACCESS_POLICY_TOKEN
    secret:
      create: false
      name: grafana-k8s-monitoring-secret
alloy-singleton:
  enabled: false
alloy-receiver:
  enabled: false
EOT
}

resource "gitsync_values_yaml" "pgadmin" {
  branch  = "main"
  path    = "values/pgadmin.yaml"
  content = <<EOT
servers:
  - name: "${local.go_template_app_name}"
    database: "${local.go_template_db_name}"
    host: "${local.go_template_db_name}-pg-rw.${local.go_template_app_name}.svc.cluster.local"
    username: "${var.pg_username}"
  - name: "${local.blog_app_name}"
    database: "${local.blog_db_name}"
    host: "${local.blog_db_name}-pg-rw.${local.blog_app_name}.svc.cluster.local"
    username: "${var.pg_username}"
EOT
}

resource "gitsync_values_yaml" "go-template" {
  branch  = "main"
  path    = "values/${local.go_template_app_name}.yaml"
  content = <<EOT
isInit: false
name: "${local.go_template_app_name}"
image: "ghcr.io/iypetrov/go-template:1.15.0"
hostname: "${cloudflare_dns_record.go_template_dns_record.name}"
replicas: 1
minMemory: "64Mi"
maxMemory: "128Mi"
minCPU: "50m"
maxCPU: "100m"
healthCheckEndpoint: "/healthz"
env:
  - name: APP_ENV
    value: "${local.env}"
  - name: APP_DOMAIN
    value: "${cloudflare_dns_record.go_template_dns_record.name}"
  - name: APP_PORT
    value: "8080"
  - name: DB_NAME
    value: "${local.go_template_db_name}"
  - name: DB_USERNAME
    valueFrom:
      secretKeyRef:
        name: "${local.go_template_app_name}-creds"
        key: PG_USERNAME
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: "${local.go_template_app_name}-creds"
        key: PG_PASSWORD
  - name: DB_ENDPOINT
    value: "${local.go_template_db_name}-pg-rw.${local.go_template_app_name}.svc.cluster.local"
  - name: DB_SSL_MODE
    value: disable
database:
  postgres:
    name: "${local.go_template_db_name}"
    host: "${local.go_template_db_name}-pg-rw.${local.go_template_app_name}.svc.cluster.local"
    image: "ghcr.io/cloudnative-pg/postgresql:16.1"
    username: "${var.pg_username}"
    storageSize: "1Gi"
    retentionPolicy: "7d"
    backupsBucket: "${aws_s3_bucket.pg_backups.bucket}"
    backupSchedule: "0 0 0 * * *"
EOT
}

resource "gitsync_values_yaml" "blog" {
  branch  = "main"
  path    = "values/${local.blog_app_name}.yaml"
  content = <<EOT
isInit: false
name: "${local.blog_app_name}"
image: "ghcr.io/iypetrov/blog:1.22.0"
hostname: "${cloudflare_dns_record.blog_dns_record.name}"
replicas: 1
minMemory: "64Mi"
maxMemory: "128Mi"
minCPU: "50m"
maxCPU: "100m"
healthCheckEndpoint: "/healthz"
env:
  - name: APP_ENV
    value: "${local.env}"
  - name: APP_DOMAIN
    value: "${cloudflare_dns_record.blog_dns_record.name}"
  - name: APP_PORT
    value: "8080"
  - name: DB_NAME
    value: "${local.blog_db_name}"
  - name: DB_USERNAME
    valueFrom:
      secretKeyRef:
        name: "${local.blog_app_name}-creds"
        key: PG_USERNAME
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: "${local.blog_app_name}-creds"
        key: PG_PASSWORD
  - name: DB_ENDPOINT
    value: "${local.blog_db_name}-pg-rw.${local.blog_app_name}.svc.cluster.local"
  - name: DB_SSL_MODE
    value: disable
  - name: SLACK_GENERAL_CHANNEL_ID
    value: "${local.slk_general_channel_id}"
  - name: SLACK_BLOG_BOT_TOKEN
    valueFrom:
      secretKeyRef:
        name:"${local.blog_app_name}-creds" 
        key: SLACK_BLOG_BOT_TOKEN
database:
  postgres:
    name: "${local.blog_db_name}"
    host: "${local.blog_db_name}-pg-rw.${local.blog_app_name}.svc.cluster.local"
    image: "ghcr.io/cloudnative-pg/postgresql:16.1"
    username: "${var.pg_username}"
    storageSize: "1Gi"
    retentionPolicy: "7d"
    backupsBucket: "${aws_s3_bucket.pg_backups.bucket}"
    backupSchedule: "0 0 0 * * *"
EOT
}
