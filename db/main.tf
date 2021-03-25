
provider "aws" {}

terraform {
  required_version = ">= 0.12.26"
}

resource "aws_db_instance" "myservice-db" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "myDB${var.env_prefix}"
  username             = var.mysql_username
  password             = var.mysql_password
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}

resource "aws_vpc" "web_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "myservice-${var.env_prefix}"
  }
}