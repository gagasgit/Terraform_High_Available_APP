provider "aws" {
  region = var.region
}

# ######## Create VPC
# resource "aws_vpc" "prod-vpc" {
#   cidr_block           = "10.0.0.0/16"
#   enable_dns_support   = "true" //gives you an internal domain name
#   enable_dns_hostnames = "true" //gives you an internal host name
#   enable_classiclink   = "false"
#   instance_tenancy     = "default"
# }


# ######## Create Public Subnet for EC2
# resource "aws_subnet" "web-subnet-public-1" {
#   vpc_id                  = aws_vpc.prod-vpc.id
#   cidr_block              = "10.0.1.0/24"
#   map_public_ip_on_launch = "true" //it makes this a public subnet
#   availability_zone       = "us-east-1a"
# }

# ######## Create Private subnet for RDS
# resource "aws_subnet" "database-subnet-private-1" {
#   vpc_id                  = aws_vpc.prod-vpc.id
#   cidr_block              = "10.0.2.0/24"
#   map_public_ip_on_launch = "false" //it makes private subnet
#   availability_zone       = "us-east-1b"
# }

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
}

####### WEB Server Security Group
resource "aws_security_group" "web" {
  name = "Lamp Dynamic Security Group"
  description = "Lamp Security Group"

  dynamic "ingress" {
    for_each = var.wb_sg_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Dynamic SecurityGroup"
  }
}

####### RDS Server Security Group
resource "aws_security_group" "database_1" {
  name = "Database SecurityGroup"
  description = "Database SecurityGroup"

  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database 1 SecurityGroup"
  }
}

####### Database RDS Server
resource "aws_db_instance" "db" {
   engine = "mariadb"
    engine_version = "10.6.7"
    instance_class = var.rds_instance_type
    db_name           = "appmariadb"
    identifier = "appmariadb"
    username = "webapp"
    password = "Pass-word01"
#    db_subnet_group_name = aws_default_subnet.prod_mariadb.name
    vpc_security_group_ids = [aws_security_group.database_1.id]
    skip_final_snapshot = true
    allocated_storage = 50
    max_allocated_storage = 1000
}


resource "aws_launch_configuration" "web" {
  //  name            = "WebServer-Highly-Available-LC"
  name_prefix     = "WebServer-Highly-Available-LC-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.ec2_instance_type
  security_groups = [aws_security_group.web.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}



resource "aws_autoscaling_group" "web" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
  load_balancers       = [aws_elb.web.name]

  dynamic "tag" {
    for_each = {
      Name   = "WebServer in ASG"
      TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_elb" "web" {
  name               = "WebServer-HA-ELB"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.web.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "WebServer-Highly-Available-ELB"
  }
}


resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}
