variable "region" {
  default = "us-east-1"
}

variable "ws_sg_ports" {
  description = "List of Ports to open for Web server"
  type        = list
  default     = ["80", "443", "22"]
}

variable "passname" {
  default = "nanada"
}

variable "rds_instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "db.t3.micro"
}

variable "postgres_database_name" {
  default = "appmariadb"
}

variable "postgres_database_user" {
  default = "webapp"
}

variable "launch_config_name" {
  default = "launch_config_ec2"
}

variable "ec2_instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t3.micro"
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

variable "database_subnet_cidrs" {
  default = [
    "10.0.21.0/24",
    "10.0.22.0/24",
    "10.0.23.0/24"
  ]
}

variable "cidr_blocks_all" {
  default = ["0.0.0.0/0"]
}


variable "db_port" {
  default     = "3306"
}
