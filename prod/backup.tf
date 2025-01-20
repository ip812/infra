# This file contains all resources related to the backups

#################################################################################
#                                     SQLite                                    #
#################################################################################

# resource "aws_iam_policy" "secrets_access" {
#   name   = "${var.organization}-${var.env}-secrets-access"
#   policy = file("policies/vm-policy.json")
# }
#
# resource "aws_iam_role_policy_attachment" "attach_secrets_access" {
#   role       = aws_iam_role.vm_role.name
#   policy_arn = aws_iam_policy.secrets_access.arn
# }
#
# resource "aws_iam_role" "sqlite_backup" {
#   name = "${var.organization}-sqlite-backup"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }
#
# resource "aws_iam_policy_attachment" "sqlite_backup_attachment" {
#   name       = "${var.organization}-sqlite-backup-attachment"
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#   roles      = [aws_iam_role.sqlite-backup.name]
# }

resource "aws_s3_bucket" "sqlite_backup" {
  bucket = "${var.organization}-sqlite-backup"
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_s3_bucket_versioning" "sqlite_backup_versioning" {
  bucket = aws_s3_bucket.sqlite_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_vpc_endpoint" "sqlite_backup_vpc_endpoint" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public_subnet_a_rt.id, aws_route_table.public_subnet_b_rt.id]
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

