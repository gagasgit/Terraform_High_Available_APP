output "web_loadbalancer_url" {
  value = aws_lb.web.dns_name
}

output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.latest_amazon_linux.name
}

output "DB_Instance_Endpoint" {
    value = module.db.db_instance_endpoint
}

output "DB_Instance_Status" {
    value = module.db.db_instance_status
}

output "RDS_password" {
  value = data.aws_ssm_parameter.rds_password.value
  sensitive = true
}