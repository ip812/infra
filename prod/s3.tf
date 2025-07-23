resource "cloudflare_r2_bucket" "go_template_bucket" {
  account_id = var.cf_account_id
  name       = "${var.org}-${var.go_template_db_name}-bucket"
  location   = "EEUR"
}

output "go_template_bucket_endpoint" {
  value = cloudflare_r2_bucket.go_template_bucket.id
}
