
### aws_vpc ###
###############
resource "aws_vpc" "expresscart_eks" {
    cidr_block              = "10.0.0.0/16"
    enable_dns_support      = true
    enable_dns_hostnames    = true

    tags            = {
        Name                                    = "expresscart_eks"
        Env                                     = "stage"
        Terraform                               = "true"
        "kubernetes.io/cluster/expresscart_eks" = "shared" 
    }
}

### public subnets ###
###############
resource "aws_subnet" "public_subnet" {
  count = length(data.aws_availability_zones.available.names)

  availability_zone         = data.aws_availability_zones.available.names[count.index]
  cidr_block                = "10.0.${count.index + 1}.0/24"
  vpc_id                    = aws_vpc.expresscart_eks.id
  map_public_ip_on_launch   = "true"

  tags = map(
    "Name", "expresscart_eks_public_subnet",
    "Env", "stage",
    "Terraform", "shared",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
    "kubernetes.io/role/elb", "1"
  )
}

### internet gateway ###
########################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.expresscart_eks.id

  tags = {
    Name        = "expresscart_eks_igw"
    Env         = "stage"
    Terraform   = "true"
  }
}

### route table ###
###################
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.expresscart_eks.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

### route table association ###
###############################
resource "aws_route_table_association" "rtba" {
  count = length(data.aws_availability_zones.available.names)

  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.rtb.id
}