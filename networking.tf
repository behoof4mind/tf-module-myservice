resource "aws_vpc" "myservice_vpc" {
  cidr_block = "172.16.0.0/16"

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

data "aws_availability_zones" "all" {}