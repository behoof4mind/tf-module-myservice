
provider "aws" {}

terraform {
  required_version = ">= 0.12.26"
}

data "aws_availability_zones" "all" {}

resource "aws_autoscaling_group" "myservice" {
  name                 = "myservice-${var.env_prefix}"
  launch_configuration = aws_launch_configuration.myservice.id
  availability_zones   = data.aws_availability_zones.all.names

  min_size = var.max_ec2_instances
  max_size = var.min_ec2_instances

  load_balancers    = [aws_elb.myservice.name]
  health_check_type = "ELB"

  tag {
    key                 = "Name"
    value               = "terraform-asg-myservice-${var.env_prefix}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "myservice" {
  name            = "myservice-${var.env_prefix}"
  image_id        = "ami-08962a4068733a2b6"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web-instance.id]

  user_data = <<-EOF
              #!/bin/bash
              nohup docker run -p ${var.server_port}:${var.server_port} -e DB_URL=${aws_db_instance.myservice-db.endpoint} -e DB_USERNAME=${var.mysql_username} -e DB_PASSWORD=${var.mysql_password} behoof4mind/myservice:${var.app_version} &
              EOF

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_db_instance.myservice-db]
}

resource "aws_security_group" "web-instance" {
  name = "myservice-instance-${var.env_prefix}"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elb" "myservice" {
  name               = "myservice-${var.env_prefix}"
  security_groups    = [aws_security_group.elb.id]
  availability_zones = data.aws_availability_zones.all.names

  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
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


resource "aws_security_group" "elb" {
  name = "myservice-${var.env_prefix}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.elb_port
    to_port     = var.elb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "web_vpc" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "myservice-${var.env_prefix}"
  }
}