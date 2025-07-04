resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [
    aws_route_table.public_subnet_a_rt.id, 
    aws_route_table.public_subnet_b_rt.id
  ]
}

resource "aws_s3_bucket" "pg_backups" {
  bucket = "pg-backups-202507041132"
}

resource "aws_s3_bucket_versioning" "pg_backups_versioning" {
  bucket = aws_s3_bucket.pg_backups.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "pg_backups_public_access_block" {
  bucket = aws_s3_bucket.pg_backups.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role" "ec2_pg_backups_role" {
  name = "ec2-cnpg-pg-backups-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_pg_backups_instance_profile" {
  name = "ec2-cnpg-pg-backups-profile"
  role = aws_iam_role.ec2_pg_backups_role.name
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

resource "aws_iam_role_policy_attachment" "attach_pg_backups_policy" {
  role       = aws_iam_role.ec2_pg_backups_role.name
  policy_arn = aws_iam_policy.pg_backups_s3_policy.arn
}

resource "aws_s3_bucket_policy" "pg_backups_policy" {
  bucket = aws_s3_bucket.pg_backups.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowEC2RoleAccess",
        Effect = "Allow",
        Principal = {
          AWS = aws_iam_role.ec2_pg_backups_role.arn
        },
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
