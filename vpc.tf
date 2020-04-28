module "vpc" {
  source                    = "terraform-aws-modules/vpc/aws"
  version                   = "~> v2.0"

  name                      = var.vpc_name
  cidr                      = "${lookup(var.cidr_ab, var.environment)}.0.0/16"
  
  # Working with local variables
  private_subnets           = local.private_subnets
  database_subnets          = local.database_subnets
  public_subnets            = local.public_subnets

  #azs                       = [
  #  "${lookup(var.region, var.environment)}a",
  #  "${lookup(var.region, var.environment)}b",
  #  "${lookup(var.region, var.environment)}c"
  #]

  # Could be
  azs = local.availability_zones

  enable_nat_gateway        = false
  single_nat_gateway        = false
  one_nat_gateway_per_az    = false
  enable_vpn_gateway        = false

  enable_dns_hostnames      = true
  enable_dns_support        = true

  tags = {
    Terraform               = var.is_project_terraformed
    Environment             = var.environment
    Owner                   = var.project_owner
    Email                   = var.project_email
    Project_Name            = var.project_name
  }
}