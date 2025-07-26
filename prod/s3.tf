resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [
    aws_route_table.public_subnet_a_rt.id,
    aws_route_table.public_subnet_b_rt.id
  ]
}

resource "aws_s3_bucket" "pg_backups" {
  bucket = "pg-backups-202507041132"
}

output "backups_bucket_name" {
  value = aws_s3_bucket.pg_backups.bucket
}

resource "aws_s3_bucket_versioning" "pg_backups_versioning" {
  bucket = aws_s3_bucket.pg_backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "pg_backups_public_access_block" {
  bucket                  = aws_s3_bucket.pg_backups.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "pg_backups_s3_policy" {
  name = "pg-backups-s3-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.pg_backups.arn,
          "${aws_s3_bucket.pg_backups.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_pg_backups_policy_to_asg_role" {
  role       = aws_iam_role.asg_role.name
  policy_arn = aws_iam_policy.pg_backups_s3_policy.arn
}

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
  domain      = "static.${var.go_template_domain}.${var.org}.com"
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

resource "cloudflare_r2_custom_domain" "blog_bucket_custom_domain" {
  account_id  = var.cf_account_id
  bucket_name = cloudflare_r2_bucket.blog_bucket.name
  domain      = "static.${var.blog_domain}.${var.org}.com"
  enabled     = true
  zone_id     = var.cf_ip812_zone_id
  min_tls     = "1.0"
}
