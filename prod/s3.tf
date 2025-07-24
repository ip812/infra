resource "cloudflare_r2_bucket" "go_template_bucket" {
  account_id    = var.cf_account_id
  name          = "${var.org}-${var.go_template_db_name}-bucket"
  location      = "EEUR"
  storage_class = "Standard"
}

output "go_template_bucket_endpoint" {
  value = cloudflare_r2_bucket.go_template_bucket.name
}

resource "cloudflare_r2_custom_domain" "go_template_bucket_custom_domain" {
  account_id  = var.cf_account_id
  bucket_name = cloudflare_r2_bucket.go_template_bucket.name
  domain      = "static.${var.blog_domain}.${var.org}.com"
  enabled     = true
  zone_id     = var.cf_ip812_zone_id
  min_tls     = "1.0"
}

resource "cloudflare_r2_bucket" "blog_bucket" {
  account_id    = var.cf_account_id
  name          = "${var.org}-${var.blog_db_name}-bucket"
  location      = "EEUR"
  storage_class = "Standard"
}

output "blog_bucket_endpoint" {
  value = cloudflare_r2_bucket.blog_bucket.name
}
