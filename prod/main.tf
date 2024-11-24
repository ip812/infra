resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Organization = var.organization
    Environment  = var.env
    CreatedAt    = timestamp()
  }
}

resource "aws_subnet" "web_subnet_primary" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.az_primary

  tags = {
    Organization = var.organization
    Environment  = var.env
    CreatedAt    = timestamp()
  }
}

resource "aws_subnet" "web_subnet_secondary" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.az_secondary

  tags = {
    Organization = var.organization
    Environment  = var.env
    CreatedAt    = timestamp()
  }
}

resource "aws_instance" "vm" {
  ami           = "ami-07c1b39b7b3d2525d"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.web_subnet_primary.id

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
