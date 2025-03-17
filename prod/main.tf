################################################################################
#                                   Variables                                  #
################################################################################

variable "aws_az_a" {
  type = string
}

variable "aws_az_b" {
  type = string
}

variable "aws_vpc_cidr" {
  type = string
}

variable "aws_public_subnet_a_cidr" {
  type = string
}

variable "aws_public_subnet_b_cidr" {
  type = string
}

variable "aws_private_subnet_a_cidr" {
  type = string
}

variable "aws_private_subnet_b_cidr" {
  type = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

################################################################################
#                                  Networking                                  #
################################################################################

resource "aws_vpc" "vpc" {
  cidr_block = var.aws_vpc_cidr
  tags       = local.default_tags
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.default_tags
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.aws_public_subnet_a_cidr
  availability_zone       = var.aws_az_a
  map_public_ip_on_launch = true
  tags                    = local.default_tags
}

resource "aws_route_table" "public_subnet_a_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = local.default_tags
}

resource "aws_route_table_association" "public_subnet_a_rt_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_subnet_a_rt.id
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.aws_public_subnet_b_cidr
  availability_zone       = var.aws_az_b
  map_public_ip_on_launch = true
  tags                    = local.default_tags
}

resource "aws_route_table" "public_subnet_b_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = local.default_tags
}

resource "aws_route_table_association" "public_subnet_b_rt_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_subnet_b_rt.id
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.aws_private_subnet_a_cidr
  availability_zone       = var.aws_az_a
  map_public_ip_on_launch = false
  tags                    = local.default_tags
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.aws_private_subnet_b_cidr
  availability_zone       = var.aws_az_b
  map_public_ip_on_launch = false
  tags                    = local.default_tags
}

################################################################################
#                                    VM                                        #
################################################################################

resource "aws_security_group" "vm_sg" {
  vpc_id  = aws_vpc.vpc.id
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
  tags = local.default_tags
}

resource "aws_iam_role" "vm_role" {
  name = "${var.org}-${var.env}-ec2-role"
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
  name = "${var.org}-${var.env}-secrets-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_secrets_access" {
  role       = aws_iam_role.vm_role.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.org}-${var.env}-ec2-profile"
  role = aws_iam_role.vm_role.name
}

resource "aws_instance" "vm" {
  ami                         = "ami-0a628e1e89aaedf80"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.vm_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
  user_data_replace_on_change = true
  user_data                   = <<-EOF
  #!/bin/bash

  # Dependencies
  echo "Updating and installing dependencies starts"
  apt-get update -y
  apt-get install -y tmux vim curl unzip
  echo "Updating and installing dependencies ends"

  # AWS CLI
  echo "Installing AWS CLI starts"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  ./aws/install
  echo "Installing AWS CLI ends"

  # AWS credentials & config
  echo "Setting up AWS credentials starts"
  mkdir -p ~/.aws
  echo -e "[default]\nregion = ${var.aws_region}\noutput = json" > ~/.aws/config
  echo -e "[default]\naws_access_key_id = ${var.aws_access_key}\naws_secret_access_key = ${var.aws_secret_key}" > ~/.aws/credentials
  echo "Setting up AWS credentials ends"

  # Dotfiles
  echo "Setting up dotfiles starts"
  cd /home/ubuntu
  git clone https://github.com/iypetrov/.vm-dotfiles.git
  chmod -R ugo+r /home/ubuntu/.vm-dotfiles
  ln -s /home/ubuntu/.vm-dotfiles/.tmux.conf /root/.tmux.conf
  ln -s /home/ubuntu/.vm-dotfiles/.vimrc /root/.vimrc
  echo "Setting up dotfiles ends"

  # Docker
  echo "Installing Docker starts"
  curl -fsSl https://get.docker.com | sh
  gpasswd -a ubuntu docker
  aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin 678468774710.dkr.ecr.${var.aws_region}.amazonaws.com
  echo "Installing Docker ends"

  # Swarm init & secrets
  echo "Setting up Docker Swarm starts"
  docker swarm init
  printf ${var.go_template_domain} | docker secret create go_template_domain -
  printf ${var.go_template_port} | docker secret create go_template_port -
  printf ${var.go_template_db_name} | docker secret create go_template_db_name -
  printf ${var.db_username} | docker secret create go_template_db_username -
  printf ${var.db_password} | docker secret create go_template_db_password -
  printf ${aws_db_instance.db.endpoint} | docker secret create go_template_db_host -
  printf ${var.go_template_db_ssl_mode} | docker secret create go_template_db_ssl_mode -
  printf ${var.aws_region} | docker secret create go_template_aws_region -
  printf ${var.aws_access_key} | docker secret create go_template_aws_access_key_id -
  printf ${var.aws_secret_key} | docker secret create go_template_aws_secret_access_key -
  echo "Setting up Docker Swarm ends"

  # Trigger deploy pipeline
  echo "Triggering Docker Swarm's deployment  starts"
  curl -X POST \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: token ${var.github_access_token}" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/ip812/apps/actions/workflows/deploy.yml/dispatches \
    -d '{"ref": "main"}'
  echo "Triggering Docker Swarm's deployment  ends"
  EOF
  tags = merge(
    local.default_tags,
    {
      Name = "${var.org}-${var.env}-core-vm"
    }
  )
}

################################################################################
#                                    DB                                        #
################################################################################

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.org}-${var.env}-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
  tags       = local.default_tags
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress = [
    {
      cidr_blocks      = [var.aws_public_subnet_a_cidr, var.aws_public_subnet_b_cidr]
      description      = "allow acces from the vm"
      from_port        = 5432
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = [aws_security_group.vm_sg.id]
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

# resource "aws_iam_role" "db_role" {
#   name = "db-${var.org}-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Service = "rds.amazonaws.com"
#       }
#       Action = "sts:AssumeRole"
#     }]
#   })
#   tags = local.default_tags
# }
# 
# resource "aws_iam_policy" "db_policy" {
#   name = "db-${var.org}-policy"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect   = "Allow"
#       Action   = ["rds-db:connect"]
#       Resource = "*"
#     }]
#   })
# }
# 
# resource "aws_iam_role_policy_attachment" "db_role_policy_attach" {
#   role       = aws_iam_role.db_role.name
#   policy_arn = aws_iam_policy.db_policy.arn
# }
# 
# resource "aws_db_instance_role_association" "db_role_attach" {
#   db_instance_identifier = aws_db_instance.db.identifier
#   feature_name           = "IAMDatabaseAuthentication"
#   role_arn               = aws_iam_role.db_role.arn
# }

resource "aws_db_instance" "db" {
  allocated_storage                   = 20
  engine                              = "postgres"
  engine_version                      = "16.8"
  identifier                          = "db-${var.org}"
  instance_class                      = "db.t4g.micro"
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids              = [aws_security_group.db_sg.id]
  storage_encrypted                   = false
  publicly_accessible                 = false
  delete_automated_backups            = false
  skip_final_snapshot                 = true
  username                            = var.db_username
  password                            = var.db_password
  apply_immediately                   = true
  multi_az                            = false
  iam_database_authentication_enabled = false
  tags                                = local.default_tags
}
