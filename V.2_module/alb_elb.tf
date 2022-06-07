module "asg_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "A security group"
  vpc_id      = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_http_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]

  tags = local.tags
}

# resource "aws_iam_service_linked_role" "autoscaling" {
#   aws_service_name = "autoscaling.amazonaws.com"
#   description      = "A service linked role for autoscaling"
#   custom_suffix    = local.name

#   # Sometimes good sleep is required to have some IAM resources created before they can be used
#   provisioner "local-exec" {
#     command = "sleep 10"
#   }
# }

# resource "aws_iam_instance_profile" "ssm" {
#   name = "complete-${local.name}"
#   role = aws_iam_role.ssm.name
#   tags = local.tags
# }

# resource "aws_iam_role" "ssm" {
#   name = "complete-${local.name}"
#   tags = local.tags

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         },
#         Effect = "Allow",
#         Sid    = ""
#       }
#     ]
#   })
# }

module "alb_http_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "~> 4.0"

  name        = "${local.name}-alb-http"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for ${local.name}"

  ingress_cidr_blocks = ["0.0.0.0/0"]

  tags = local.tags
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = local.name

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_http_sg.security_group_id]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  target_groups = [
    {
      name             = local.name
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
  ]

  tags = local.tags
}

# resource "aws_ec2_capacity_reservation" "targeted" {
#   instance_type           = "t3.micro"
#   instance_platform       = "Linux/UNIX"
#   availability_zone       = "${var.region}a"
#   instance_count          = 1
#   instance_match_criteria = "targeted"
# }