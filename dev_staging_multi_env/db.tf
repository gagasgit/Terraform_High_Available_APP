
module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.db_sg
  description = "Complete MySQL example security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = var.db_port
      to_port     = var.db_port
      protocol    = "tcp"
      description = "MySQL access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]

  tags = var.common_tags
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
  name        = "/database"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_password.result
}

// Get Password from SSM Parameter Store
  data "aws_ssm_parameter" "rds_password" {
  name       = "/database"
  depends_on = [aws_ssm_parameter.rds_password]
}


module "db" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 4.4"
  identifier = var.database_name

  # All available versions: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MySQL.html#MySQL.Concepts.VersionMgmt
  engine               = "mysql"
  engine_version       = "8.0.27"
  family               = "mysql8.0" # DB parameter group
  major_engine_version = "8.0"      # DB option group
  instance_class       = var.rds_instance_type

  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = var.database_name
  username = var.database_user
  password = "data.aws_ssm_parameter.rds_password.value"
  port     = var.db_port

  multi_az               = true
  #db_subnet_group_name   = module.vpc.private_subnets_group
  vpc_security_group_ids = [module.security_group.security_group_id]


  create_db_subnet_group = true
  subnet_ids             = module.vpc.private_subnets

  create_cloudwatch_log_group     = false

  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = false
  create_monitoring_role                = false

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  tags = var.common_tags

  db_instance_tags = {
    "Sensitive" = "high"
  }
  db_option_group_tags = {
    "Sensitive" = "low"
  }
  db_parameter_group_tags = {
    "Sensitive" = "low"
  }
  db_subnet_group_tags = {
    "Sensitive" = "high"
  }
}
