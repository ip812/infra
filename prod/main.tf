resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Organization = var.organization
    Environment  = var.env
    CreatedAt    = timestamp()
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Organization = var.organization
    Environment  = var.env
    CreatedAt    = timestamp()
  }
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Organization = var.organization
    Environment  = var.env
    CreatedAt    = timestamp()
  }
}

resource "aws_instance" "vm" {
  ami           = "ami-07c1b39b7b3d2525d"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subnet.id

  tags = {
    Organization = var.organization
    Environment  = var.env
    CreatedAt    = timestamp()
  }
}

resource "aws_eip" "eip" {
  domain     = "vpc"
  instance   = aws_instance.vm.id
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Organization = var.organization
    Environment  = var.env
    CreatedAt    = timestamp()
  }
}
