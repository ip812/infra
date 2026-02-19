resource "cloudflare_r2_bucket" "go_template_bucket" {
  account_id    = var.cf_account_id
  name          = "${local.org}-${local.go_template_db_name}-bucket"
  location      = "EEUR"
  storage_class = "Standard"
}

resource "cloudflare_r2_custom_domain" "go_template_bucket_custom_domain" {
  account_id  = var.cf_account_id
  bucket_name = cloudflare_r2_bucket.go_template_bucket.name
  domain      = "static.${local.go_template_domain}.${local.org}.com"
  enabled     = true
  zone_id     = var.cf_ip812_zone_id
  min_tls     = "1.0"
}

resource "cloudflare_r2_bucket" "blog_bucket" {
  account_id    = var.cf_account_id
  name          = "${local.org}-${local.blog_db_name}-bucket"
  location      = "EEUR"
  storage_class = "Standard"
}

resource "cloudflare_r2_custom_domain" "blog_bucket_custom_domain" {
  account_id  = var.cf_account_id
  bucket_name = cloudflare_r2_bucket.blog_bucket.name
  domain      = "static.${local.blog_domain}.${local.org}.com"
  enabled     = true
  zone_id     = var.cf_ip812_zone_id
  min_tls     = "1.0"
}

resource "cloudflare_r2_bucket" "family_drive_bucket" {
  account_id    = var.cf_account_id
  name          = "${local.org}-${local.family_drive_name}-bucket"
  location      = "EEUR"
  storage_class = "Standard"
}
