
resource "aws_vpc" "web_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "myservice"
  }
}

resource "aws_subnet" "web_subnet" {
  vpc_id            = aws_vpc.web_vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "myservice"
  }
}

resource "aws_network_interface" "web" {
  subnet_id   = aws_subnet.web_subnet.id
  private_ips = ["172.16.10.100"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "web" {
  ami           = "ami-08962a4068733a2b6"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.web.id
    device_index         = 0
  }

  credit_specification {
    cpu_credits = "unlimited"
  }
}