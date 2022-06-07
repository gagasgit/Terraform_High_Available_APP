provider "aws" {
  region = var.region
}

locals {
  name   = "HA"
  tags = {
    Owner       = "HA_user"
    Environment = "dev"
  }
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "VPC_HA"
  cidr = "10.0.0.0/16"

  azs              = ["${var.region}a", "${var.region}b"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24"]
  database_subnets = ["10.0.7.0/24", "10.0.8.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
}

# ####### WEB Server Security Group
# resource "aws_security_group" "web" {
#   name = "Lamp Dynamic Security Group"
#   description = "Lamp Security Group"
#   vpc_id      = module.vpc.vpc_id

#   dynamic "ingress" {
#     for_each = var.ws_sg_ports
#     content {
#       from_port   = ingress.value
#       to_port     = ingress.value
#       protocol    = "tcp"
#       cidr_blocks = ["0.0.0.0/0"]
#     }
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name  = "Dynamic SecurityGroup"
#   }
# }


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Complete MySQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    },
  ]

  tags = local.tags
}


// Generate Password
resource "random_string" "rds_password" {
  length           = 12
  special          = true
  override_special = "#%*@"

  keepers = {
    passwordchanger = var.passname
  }
}

// Store Password in SSM Parameter Store
resource "aws_ssm_parameter" "rds_password" {
  name        = "/mariadb"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}

// Get Password from SSM Parameter Store
  data "aws_ssm_parameter" "rds_password" {
  name       = "/mariadb"
  depends_on = [aws_ssm_parameter.rds_password]
}


# module "db" {
#   source = "terraform-aws-modules/rds/aws"

#   identifier = var.postgres_database_name

#   # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
#   engine               = "mysql"
#   engine_version       = "8.0.27"
#   family               = "mysql8.0" # DB parameter group
#   major_engine_version = "8.0"      # DB option group
#   instance_class       = var.rds_instance_type

#   allocated_storage     = 20
#   max_allocated_storage = 100

#   db_name  = var.postgres_database_name
#   username = var.postgres_database_user
#   port     = 3306

#   multi_az               = true
#   subnet_ids             = module.vpc.database_subnets
#   vpc_security_group_ids = [module.security_group.security_group_id]

#   maintenance_window              = "Mon:00:00-Mon:03:00"
#   backup_window                   = "03:00-06:00"
#   enabled_cloudwatch_logs_exports = ["general"]
#   create_cloudwatch_log_group     = true

#   backup_retention_period = 0
#   skip_final_snapshot     = true
#   deletion_protection     = false

#   performance_insights_enabled          = true
#   performance_insights_retention_period = 7
#   create_monitoring_role                = true
#   monitoring_interval                   = 60

#   parameters = [
#     {
#       name  = "character_set_client"
#       value = "utf8mb4"
#     },
#     {
#       name  = "character_set_server"
#       value = "utf8mb4"
#     }
#   ]

#   tags = local.tags
#   db_instance_tags = {
#     "Sensitive" = "high"
#   }
#   db_option_group_tags = {
#     "Sensitive" = "low"
#   }
#   db_parameter_group_tags = {
#     "Sensitive" = "low"
#   }
#   db_subnet_group_tags = {
#     "Sensitive" = "high"
#   }
# }

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.postgres_database_name

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine               = "postgres"
  engine_version       = "14.1"
  family               = "postgres14" # DB parameter group
  major_engine_version = "14"         # DB option group
  instance_class       = var.rds_instance_type

  allocated_storage     = 20
  max_allocated_storage = 100

  # NOTE: Do NOT use 'user' as the value for 'username' as it throws:
  # "Error creating DB Instance: InvalidParameterValue: MasterUsername
  # user cannot be used as it is a reserved word used by the engine"
  db_name  = var.postgres_database_name
  username = var.postgres_database_user
  port     = 5432

  multi_az               = true
  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "example-monitoring-role-name"
  monitoring_role_description           = "Description for monitoring role"

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]

  tags = local.tags
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
}


