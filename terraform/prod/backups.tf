resource "cloudflare_r2_bucket" "pg_backups_bucket" {
  account_id    = var.cf_account_id
  name          = "${local.org}-pg-backups-bucket"
  location      = "EEUR"
  storage_class = "Standard"
}

resource "cloudflare_r2_bucket" "k8s_work_01_etcd_bucket" {
  account_id    = var.cf_account_id
  name          = "${local.org}-${local.env}-work-01-etcd-bucket"
  location      = "EEUR"
  storage_class = "Standard"
}
