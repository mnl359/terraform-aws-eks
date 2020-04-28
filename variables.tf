/* Project Tags */

variable "project_owner" {
    description     = "Tag to identify the resource owner name"
    default         = "William Munoz"
}

variable "project_email" {
    description     = "Tag to identify the resource owner email"
    default         = "william.munoz@endava.com"
} 

variable "project_name" {
    description     = "Tag to identify the resource project name"
    default         = "CircleCI"
}

variable "is_project_terraformed" {
    description     = "Tag to identify if the project is managed by Terraform"
    default         = "true"
}

/* Region */

variable "region" {
    type            = map(string)
    default         = {
        "development"   = "us-east-1"
        "qa"            = "us-east-1"
        "staging"       = "us-east-2"
        "production"    = "us-east-2"
    }
}

/* Environment Definition */

variable "environment" {
    description     = "Environment Definition - Options: development, qa, staging, production"
    default         = "development"
}

/* VPC Configuration */

variable "vpc_name" {
    description     = "VPC Name"
    default         = "terraform-ansible-01"
}

variable "cidr_ab" {
    type = map
    default = {
        development = "172.22"
        qa          = "172.24"
        staging     = "172.26"
        production  = "172.28"
    }
}

locals {
  cidr_c_private_subnets    = 1
  cidr_c_database_subnets   = 11
  cidr_c_public_subnets     = 64

  max_private_subnets       = 2
  max_database_subnets      = 2
  max_public_subnets        = 3
}

locals {
    availability_zones  = data.aws_availability_zones.available.names
}

/* Subnets Configuration */

locals {
    private_subnets = [
        for az in local.availability_zones :
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_private_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_private_subnets
    ]

    database_subnets = [
        for az in local.availability_zones :
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_database_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_database_subnets
    ]

    public_subnets = [
        for az in local.availability_zones :
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_public_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_public_subnets
    ]
}

/* Security Groups Names */

variable "web_sg_name" {
    description     = "Web Security Group Name"
    default         = "web_sg_01"
}

variable "web_sg_description" {
    description     = "Web Security Group Description"
    default         = "Allow incoming HTTP connections"
}

variable "alb_sg_name" {
    description     = "ALB Security Group Name"
    default         = "alb_sg_01"
}

variable "alb_sg_description" {
    description     = "ALB Security Group Description"
    default         = "Terraform Ansible ALB Security Group"
}

variable "db_sg_name" {
    description     = "DB Security Group Name"
    default         = "db_sg"  
}

variable "db_sg_description" {
    description     = "DB Security Group Description"
    default         = "Allow incoming database connections from public web servers"
}


/* EC2 Configuration Init */

variable "aws_amis" {
    description     = "AMIs by Region"
    default = {
        us-east-1 = "ami-00068cd7555f543d5" # ami-00068cd7555f543d5 Amazon Linux 2 AMI
    }
}

variable "ec2_machine_type" {
    description     = "Cloud Machine Type"
    default         = "t2.micro"
}

# Number of EC2 Instances
variable "number_of_instances" {
    description     = "Number of instances"
    default         = 1 
}

variable "key_name" {
    description     = "AWS Key Name"
    default         = "terraform-ansible-01"
}

variable "ssh_public_key" {
    description     = "Public Key for Terraform-Ansible Project"
    default         = "terraform-ansible-aws.pub"
}

/* Instances Tags */

variable "instance_name" {
    description     = "Tag for the instances name"
    default         = "App01"
}

/* RDS Configuration Init */

variable "rds_database_identifier" {
    description     = "RDS Database Identifier"
    default         = "terraform-ansible-01"
}

variable "rds_instance_class" {
    description     = "RDS Instance Class"
    default         = "db.t2.micro"
}

variable "rds_database_name" {
    description     = "RDS Database Name"
    default         = "terraformansible01"
}

variable "rds_database_username" {
    description     = "RDS Database Username"
    default         = "admindb"
}

# Bad practice: create a secret
variable "rds_database_password" {
    description     = "RDS Database Password"
    default         = "a1s2d3f4"
}

variable "rds_subnet_group_name" {
    description     = "RDS Subnet Group Name"
    default         = "db_private_subnet_01"
}

variable "rds_allocated_storage" {
    description     = "RDS Storage to Allocate"
    default         = 20  
}

variable "rds_storage_type" {
    description     = "RDS Storage Type"
    default         = "gp2"
}

variable "rds_engine" {
    description     = "RDS Engine"
    default         = "mysql"
}

variable "rds_engine_version" {
    description     = "RDS Engine Version"
    default         = "5.7"
}

variable "rds_parameter_group_name" {
    description     = "RDS Parameter Group Name"
    default         = "default.mysql5.7"
}

/* Application Load Balancer */

variable "alb_name" {
    description     = "ALB Name"
    default         = "terraform-ansible-alb-01"
}

variable "alb_type" {
    description     = "ALB Type"
    default         = "application"
}

