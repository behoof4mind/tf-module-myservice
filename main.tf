
provider "aws" {}

terraform {
  required_version = ">= 0.12.26"
}

resource "aws_autoscaling_group" "myservice" {
  name                 = "myservice-${var.env_prefix}"
  launch_configuration = aws_launch_configuration.myservice.id
  //  availability_zones   = data.aws_availability_zones.all.names
  vpc_zone_identifier = [aws_subnet.myservice_a.id, aws_subnet.myservice_b.id, aws_subnet.myservice_c.id]

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
  name          = "myservice-${var.env_prefix}"
  image_id      = "ami-000e7ce4dd68e7a11"
  instance_type = "t2.micro"
  // public ip should be turned off after tests
  associate_public_ip_address = true
  //  security_groups = [aws_security_group.http-web-access.id, aws_security_group.https-web-access.id, aws_security_group.ssh-access.id,aws_security_group.db-access.id]
  security_groups = [aws_security_group.elb.id]

  user_data = <<-REALEND
              #!/bin/bash
              #!/bin/bash
              echo "started" >> /home/ubuntu/userdata.state
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo apt install mysql-client
              mysql -h ${aws_db_instance.myservice-db.endpoint} -u ${var.mysql_username} -p${var.mysql_password} -e "create database if not exists myservice"

              usermod -aG docker ubuntu

              sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
              sudo chmod +x /usr/local/bin/docker-compose

              sudo usermod -aG docker $USER

              cat <<EOF >/home/ubuntu/docker-compose.yml
              myservice:
                image: behoof4mind/myservice:${var.app_version}
                ports:
                  - "80:4000"
              EOF

              sudo chown ubuntu:ubuntu /home/ubuntu/docker-compose.yml
              sudo docker-compose up -d
              echo "finished" >> /home/ubuntu/userdata.state
              REALEND

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "myservice" {
  name            = "myservice-${var.env_prefix}"
  security_groups = [aws_security_group.elb.id]
  //  availability_zones = data.aws_availability_zones.all.names
  subnets = [aws_subnet.myservice_c.id, aws_subnet.myservice_b.id, aws_subnet.myservice_a.id]

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
}

resource "aws_db_instance" "myservice-db" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.myservice.name
  name                   = "myDB${var.env_prefix}"
  username               = var.mysql_username
  password               = var.mysql_password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.elb.id]
  skip_final_snapshot    = true
}