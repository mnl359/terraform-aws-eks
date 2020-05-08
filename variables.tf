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
    default         = "Kubernetes"
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
    default         = "terraform-eks-01"
}

variable "cidr_ab" {
    type = map
    default = {
        development = "172.20"
        qa          = "172.21"
        staging     = "172.22"
        production  = "172.23"
    }
}

locals {
  cidr_c_private_subnets    = 1
  cidr_c_public_subnets     = 64

  max_private_subnets       = 1
  max_public_subnets        = 2
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

    public_subnets = [
        for az in local.availability_zones :
            "${lookup(var.cidr_ab, var.environment)}.${local.cidr_c_public_subnets + index(local.availability_zones, az)}.0/24"
            if index(local.availability_zones, az) < local.max_public_subnets
    ]
}

/* EKS Wordpress Cluster */
variable "eks_cluster_name" {
    description     = "EKS Cluster Name"
    default         = "eks-wordpress"
}

/* EKS Wordpress Worker Nodes */
variable "eks_instance_type" {
    description     = "EKS Instance Type"
    default         = "t2.medium"
}

/* EKS Auto Scaling Group Max Size */
variable "eks_asg_max_size" {
    description     = "EKS Auto Scaling Group Max Size"
    default         = 1
}

variable "asg_desired_capacity" {
    description     = "Desired Capacity"
    default         = 1
}