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