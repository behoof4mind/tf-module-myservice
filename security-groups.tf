resource "aws_security_group" "http-web-access" {
  name = "myservice-http-${var.env_prefix}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
}

resource "aws_security_group" "https-web-access" {
  name = "myservice-https-${var.env_prefix}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }
}

resource "aws_security_group" "ssh-access" {
  name = "myservice-ssh-${var.env_prefix}"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = var.server_port
    protocol = "tcp"
    to_port = 80
  }
}

resource "aws_security_group" "db-access" {
  name = "myservice-db-${var.env_prefix}"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.myservice_vpc.cidr_block]
  }
  egress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = [aws_vpc.myservice_vpc.cidr_block]
  }
}