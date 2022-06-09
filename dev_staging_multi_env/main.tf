provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "bucket-name-3213289798da"
    key    = "dev/dev1/terraform.tfstate"
    region = "us-east-1"
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "VPC_HA"
  cidr = var.vpc_cidr

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets  = var.private_subnet_cidrs
  public_subnets   = var.public_subnet_cidrs

  create_database_subnet_group = true
  create_database_subnet_route_table = true

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
    values = var.aws_ami
  }
}
