
### aws_vpc ###
###############
resource "aws_vpc" "expresscart_eks" {
    cidr_block      = "10.0.0.0/16"
    enable_dns_support = true

    tags            = {
        Name                                    = "expresscart_eks"
        Env                                     = "stage"
        Terraform                               = "true"
        "kubernetes.io/cluster/expresscart_eks" = "shared" 
    }
}

### public subnet us-east-1a ###
#################################
resource "aws_subnet" "public-1a" {
    vpc_id                      = aws_vpc.expresscart_eks.id
    cidr_block                  = "10.0.10.0/24"
    availability_zone           = "us-east-1a"
    map_public_ip_on_launch     = "true"

    tags = {
        Name                                    = "expresscart_eks_public_subnet"
        Env                                     = "stage"
        Terraform                               = "true"
        "kubernetes.io/cluster/expresscart_eks" = "shared"
        "kubernetes.io/role/elb"                = "1"
    }
}

### public subnet us-east-1b ###
################################
resource "aws_subnet" "public-1b" {
    vpc_id                      = aws_vpc.expresscart_eks.id
    cidr_block                  = "10.0.20.0/24"
    availability_zone           = "us-east-1b"
    map_public_ip_on_launch     = "true"

    tags = {
        Name                                    = "expresscart_eks_public_subnet"
        Env                                     = "stage"
        Terraform                               = "true"
        "kubernetes.io/cluster/expresscart_eks" = "shared"
        "kubernetes.io/role/elb"                = "1"
    }
}

### public subnet us-east-1c ###
################################
resource "aws_subnet" "public-1c" {
    vpc_id                      = aws_vpc.expresscart_eks.id
    cidr_block                  = "10.0.30.0/24"
    availability_zone           = "us-east-1c"
    map_public_ip_on_launch     = "true"

    tags = {
        Name                                    = "expresscart_eks_public_subnet"
        Env                                     = "stage"
        Terraform                               = "true"
        "kubernetes.io/cluster/expresscart_eks" = "shared"
        "kubernetes.io/role/elb"                = "1"
    }
}

### internet gateway ###
########################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.expresscart_eks.id

  tags = {
    Name = "expresscart_eks_igw"
  }
}