################################################################################
#                                   Variables                                  #
################################################################################

variable "pg_username" {
  type      = string
  sensitive = true
}

output "pg_username" {
  value     = var.pg_username
  sensitive = true
}

variable "pg_password" {
  type      = string
  sensitive = true
}

output "pg_password" {
  value     = var.pg_password
  sensitive = true
}

################################################################################
#                                   Postgres                                   #
################################################################################

resource "aws_db_subnet_group" "pg_subnet_group" {
  name       = "${var.org}-${var.env}-pg-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  tags       = local.default_tags
}

resource "aws_security_group" "pg_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress = [
    {
      cidr_blocks      = [var.aws_public_subnet_a_cidr, var.aws_public_subnet_b_cidr]
      description      = "allow acces from the asg"
      from_port        = 5432
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [aws_security_group.asg_sg.id]
      self             = false
      to_port          = 5432
    }
  ]
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "patches"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = -1
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  tags = local.default_tags
}

resource "aws_db_instance" "pg" {
  allocated_storage                     = 20
  engine                                = "postgres"
  engine_version                        = "16.8"
  identifier                            = "pg-${var.org}"
  instance_class                        = "db.t4g.micro"
  db_subnet_group_name                  = aws_db_subnet_group.pg_subnet_group.name
  vpc_security_group_ids                = [aws_security_group.pg_sg.id]
  storage_encrypted                     = false
  publicly_accessible                   = false
  delete_automated_backups              = false
  skip_final_snapshot                   = true
  username                              = var.pg_username
  password                              = var.pg_password
  apply_immediately                     = true
  multi_az                              = false
  iam_database_authentication_enabled   = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  backup_window                         = "00:00-01:00"
  backup_retention_period               = 7
  tags                                  = local.default_tags

  lifecycle {
    replace_triggered_by = [
      aws_security_group.pg_sg,
      aws_security_group.pg_sg.ingress,
      aws_security_group.pg_sg.egress
    ]
  }
}

output "pg_endpoint" {
  value     = aws_db_instance.pg.endpoint
  sensitive = true
}
