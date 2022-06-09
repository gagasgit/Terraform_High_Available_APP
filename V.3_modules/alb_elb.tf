resource "aws_security_group" "web_instance" {
  name = "asg-web-instance"

  vpc_id = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = ["80", "443"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
#      security_groups = [aws_security_group.web_lb.id]
  }
}

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = ["0.0.0.0/0"]
#    security_groups = [aws_security_group.web_lb.id]
  }

  tags = local.tags
}

resource "aws_security_group" "web_lb" {
  name = "asg-web-lb"
  
  vpc_id = module.vpc.vpc_id

  dynamic "ingress" {
    for_each = ["80", "443"]
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

  tags = local.tags
}

resource "aws_launch_configuration" "web" {
  //  name            = "WebServer-Highly-Available-LC"
  name_prefix     = "WebServer-Highly-Available-LC-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.ec2_instance_type
  security_groups = [aws_security_group.web_instance.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
  
#  depends_on = [aws_db_instance.db]
}


resource "aws_autoscaling_group" "web" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  min_size             = 3
  max_size             = 3
  desired_capacity     = 3
  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.web.name
  vpc_zone_identifier  = module.vpc.private_subnets

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb" "web" {
  name               = "web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_lb.id]
  subnets            = module.vpc.public_subnets


}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

 resource "aws_lb_target_group" "web" {
   name     = "web-asg"
   port     = 80
   protocol = "HTTP"
   vpc_id   = module.vpc.vpc_id
 }

resource "aws_autoscaling_attachment" "web" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  lb_target_group_arn   = aws_lb_target_group.web.arn
}
