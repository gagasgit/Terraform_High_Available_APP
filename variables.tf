variable "region" {
  description = "Enter AWS Region to deploy Server"
  type        = string
  default     = "us-east-1"
}

variable "ec2_instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "t3.micro"
}

variable "rds_instance_type" {
  description = "Enter Instance Type"
  type        = string
  default     = "db.t3.micro"
}


variable "ws_sg_ports" {
  description = "List of Ports to open for Web server"
  type        = list
  default     = ["80", "443", "22"]
}



variable "tags" {
  description = "Common Tags to apply to all resources"
  type        = map
  default = {
  Project     = "Lamp"
  Environment = "prod"
  }
}

variable "name"{
  description = "Name"
  type        = string
  default     = "prod"
}

variable "passname" {
  default = "nanada"
}