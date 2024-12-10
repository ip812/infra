resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
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
  cidr_block        = var.public_subnet_a_cidr
  availability_zone = var.az_a
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
  cidr_block        = var.public_subnet_b_cidr
  availability_zone = var.az_b
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

resource "aws_key_pair" "vm_ssh_public_key" {
  key_name   = "vm-ssh-key"
  public_key = var.vm_ssh_public_key
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
  key_name               = aws_key_pair.vm_ssh_public_key.key_name
  user_data              = file("scripts/vm-setup.sh")
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}

resource "aws_eip" "eip" {
  domain     = "vpc"
  instance   = aws_instance.vm.id
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Organization = var.organization
    Environment  = var.env
  }
}
