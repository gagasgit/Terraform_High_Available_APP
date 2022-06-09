region                     = "us-east-1"

rds_instance_type          = "db.t3.micro"

ec2_instance_type          = "t3.micro"

ws_sg_ports = ["80", "443"]

tags = {
  Project     = "Lamp"
  Environment = "prod"
}


