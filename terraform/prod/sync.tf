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
image: "ghcr.io/iypetrov/blog:1.25.2"
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
        name: "${local.blog_app_name}-creds" 
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
