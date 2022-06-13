variable "region" {
  default = "us-east-1"
}

variable "aws_ami" {
  default     = ["amzn2-ami-kernel-*-x86_64-gp2"]
}

variable "ec2_instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "web_ports" {
  description = "List of Ports for Web server"
  type        = list
  default     = ["80", "443"]
}

variable "db_port" {
  default     = "3306"
}

variable "passname" {
  default = "nanada"
}

variable "rds_instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "db.t3.micro"
}

variable "database_name" {
  default = "webappdb"
}

variable "database_user" {
  default = "webapp"
}

variable "launch_config_name" {
  default = "launch_config_ec2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]
}
variable "cidr_blocks_all" {
  default = ["0.0.0.0/0"]
}

variable "common_tags" {
  description = "Common Tags for all resources"
  type        = map
  default = {
    Project     = "HA_WE_APP"
    Environment = "Development"
  }
}

variable "db_sg" {
  default = "Database_SG"
}

variable "min_size" {
  default = "3"
}

variable "max_size" {
  default = "3"
}

variable "desired_capacity" {
  default = "3"
}
