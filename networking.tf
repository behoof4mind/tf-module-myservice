resource "aws_vpc" "myservice_vpc" {
  cidr_block = "172.16.0.0/16"
  enable_dns_support   = true

  tags = {
    Name = "myservice-${var.env_prefix}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.myservice_vpc.id

  tags = {
    Name = "myservice"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.myservice_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "myservice"
  }
}

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.myservice_a.id
  route_table_id = aws_route_table.r.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.myservice_b.id
  route_table_id = aws_route_table.r.id
}

resource "aws_route_table_association" "a3" {
  subnet_id      = aws_subnet.myservice_c.id
  route_table_id = aws_route_table.r.id
}

resource "aws_route_table_association" "agw" {
  subnet_id      = aws_internet_gateway.gw.id
  route_table_id = aws_route_table.r.id
}

resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.myservice_vpc.id
  route_table_id = aws_internet_gateway.gw.id
}

resource "aws_subnet" "myservice_a" {
  vpc_id     = aws_vpc.myservice_vpc.id
  availability_zone = "us-east-2a"
  cidr_block = "172.16.10.0/24"

  tags = {
    Name = "myservice-${var.env_prefix}-a"
  }
}

resource "aws_subnet" "myservice_b" {
  vpc_id     = aws_vpc.myservice_vpc.id
  availability_zone = "us-east-2b"
  cidr_block = "172.16.20.0/24"

  tags = {
    Name = "myservice-${var.env_prefix}-b"
  }
}

resource "aws_subnet" "myservice_c" {
  vpc_id     = aws_vpc.myservice_vpc.id
  availability_zone = "us-east-2c"
  cidr_block = "172.16.3.0/24"

  tags = {
    Name = "myservice-${var.env_prefix}-c"
  }
}

resource "aws_db_subnet_group" "myservice" {
  name       = "myservice-rds-subnet-group"
  subnet_ids = [aws_subnet.myservice_a.id, aws_subnet.myservice_b.id, aws_subnet.myservice_c.id]

  tags = {
    Name = "myservice DB subnet group"
  }
}

data "aws_availability_zones" "all" {}