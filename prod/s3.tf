resource "cloudflare_r2_bucket" "go_template_bucket" {
  account_id = var.cf_account_id
  name       = "${var.org}-${var.go_template_db_name}-bucket"
  location   = "EEUR"
}

output "go_template_bucket_endpoint" {
  value = cloudflare_r2_bucket.go_template_bucket.name
}

resource "cloudflare_worker_script" "go_template_serve_files" {
  account_id = var.cf_account_id
  name       = "go-template-serve-files"
  content    = file("${path.module}/scripts/serve_files.js")

  r2_bucket_binding {
    name        = "FILES_BUCKET"
    bucket_name = cloudflare_r2_bucket.go_template_bucket.name
  }
}

resource "cloudflare_r2_bucket" "blog_bucket" {
  account_id = var.cf_account_id
  name       = "${var.org}-${var.blog_db_name}-bucket"
  location   = "EEUR"
}

output "blog_bucket_endpoint" {
  value = cloudflare_r2_bucket.blog_bucket.name
}

resource "cloudflare_worker_script" "blog_serve_files" {
  account_id = var.cf_account_id
  name       = "blog-serve-files"
  content    = file("${path.module}/scripts/serve_files.js")

  r2_bucket_binding {
    name        = "FILES_BUCKET"
    bucket_name = cloudflare_r2_bucket.blog_bucket.name
  }
}
