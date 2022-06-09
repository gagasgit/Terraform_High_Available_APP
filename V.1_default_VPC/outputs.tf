#--------------------------------------------------
output "web_loadbalancer_url" {
  value = aws_elb.web.dns_name
}

output "latest_amazon_linux_ami_id" {
  value = data.aws_ami.latest_amazon_linux.id
}

output "latest_amazon_linux_ami_name" {
  value = data.aws_ami.latest_amazon_linux.name
}

output "this_db_instance_endpoint" {
    value = aws_db_instance.db.endpoint
}

output "this_db_instance_status" {
    value = aws_db_instance.db.status
}

output "rds_password" {
  value = data.aws_ssm_parameter.rds_password.value
  sensitive = true
}
