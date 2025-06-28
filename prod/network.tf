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
