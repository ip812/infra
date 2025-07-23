resource "cloudflare_r2_bucket" "app_s3" {
  account_id = var.cf_account_id
  name       = "${var.org}-${var.go_template_db_name}-bucket"
  location   = "EEUR"
}
