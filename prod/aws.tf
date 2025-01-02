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
  depends_on     = [aws_subnet.public_subnet_a, aws_route_table.public_subnet_a_rt]
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_subnet_a_rt.id
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.aws_public_subnet_b_cidr
  availability_zone = var.aws_az_b
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
  depends_on     = [aws_subnet.public_subnet_b, aws_route_table.public_subnet_b_rt]
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_subnet_b_rt.id
}

resource "aws_security_group" "vm_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "ssh"
      from_port        = 22
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 22
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "http"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "https"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    },
  ]
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = ""
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

resource "aws_instance" "vm" {
  ami                    = "ami-07c1b39b7b3d2525d"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_a.id
  vpc_security_group_ids = [aws_security_group.vm_sg.id]
  user_data = templatefile("scripts/vm-setup.sh", {
    admin_ssh_public_key = var.admin_ssh_public_key
    deploy_ssh_public_key = var.deploy_ssh_public_key
    github_access_token= var.github_access_token
  })
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
  domain     = "vpc"
  instance   = aws_instance.vm.id
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_secretsmanager_secret" "blog_addr" {
  name            = "blog_addr"
}

resource "aws_secretsmanager_secret_version" "blog_addr_version" {
  secret_id     = aws_secretsmanager_secret.blog_addr.id
  secret_string = var.blog_domain
}

resource "aws_secretsmanager_secret" "blog_db_file" {
  name            = "blog_db_file"
}

resource "aws_secretsmanager_secret_version" "blog_db_file_version" {
  secret_id     = aws_secretsmanager_secret.blog_db_file.id
  secret_string = var.blog_db_file
}

resource "aws_secretsmanager_secret" "blog_port" {
  name            = "blog_port"
}

resource "aws_secretsmanager_secret_version" "blog_port_version" {
  secret_id     = aws_secretsmanager_secret.blog_port.id
  secret_string = var.blog_port
}
