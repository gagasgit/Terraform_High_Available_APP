variable "region" {
  description = "Enter AWS Region to deploy Server"
  type        = string
  default     = "us-east-1"
}

variable "ec2_instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t2.small"
}

variable "rds_instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "db.t3.micro"
}


variable "wb_sg_ports" {
  description = "List of Ports to open for Web server"
  type        = list
  default     = ["80", "443", "22"]
}