resource "aws_vpc" "vpc" {
  cidr_block = var.aws_vpc_cidr
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.aws_public_subnet_a_cidr
  availability_zone = var.aws_az_a
  map_public_ip_on_launch = true
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_route_table" "public_subnet_a_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_route_table_association" "public_subnet_a_rt_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_subnet_a_rt.id
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.aws_public_subnet_b_cidr
  availability_zone = var.aws_az_b
  map_public_ip_on_launch = true
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_route_table" "public_subnet_b_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_route_table_association" "public_subnet_b_rt_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_subnet_b_rt.id
}

resource "aws_security_group" "vm_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress = []
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "session manager"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = -1
      security_groups  = []
      self             = false
      to_port          = 0
    },
  ]
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_iam_role" "vm_role" {
  name = "${var.organization}-${var.env}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_access" {
  name   = "${var.organization}-${var.env}-secrets-access"
  policy = file("policies/vm-policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_secrets_access" {
  role       = aws_iam_role.vm_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.organization}-${var.env}-ec2-profile"
  role = aws_iam_role.vm_role.name
}

resource "aws_instance" "vm" {
  ami                    = "ami-0a628e1e89aaedf80"
  instance_type          = "t2.micro"
  associate_public_ip_address = true
  subnet_id              = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.vm_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  user_data = templatefile("scripts/vm-setup.sh", {
    github_access_token        = var.github_access_token
    ip812_tunnel_token         = cloudflare_zero_trust_tunnel_cloudflared.ip812_tunnel.tunnel_token
    blog_domain                = var.blog_domain
    blog_port                  = var.blog_port
    blog_db_file               = var.blog_db_file
    blog_aws_region            = var.aws_region
    blog_aws_access_key_id     = var.aws_access_key
    blog_aws_secret_access_key = var.aws_secret_key
  })
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

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
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.public_subnet_a_rt.id, aws_route_table.public_subnet_b_rt.id]
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}
