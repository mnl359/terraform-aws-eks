#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * IAM role allowing Kubernetes actions to access other AWS services

# IAM Role to allow EKS service to manage other AWS services
resource "aws_iam_role" "hachiko-cluster" {
  name = "expresscart-eks-hachiko-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "hachiko-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.hachiko-cluster.name
}

resource "aws_iam_role_policy_attachment" "hachiko-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.hachiko-cluster.name
}

# IAM role allowing Kubernetes actions to access other AWS services
resource "aws_iam_role" "hachiko-node" {
  name = "expresscart-eks-hachiko-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "hachiko-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.hachiko-node.name
}

resource "aws_iam_role_policy_attachment" "hachiko-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.hachiko-node.name
}

resource "aws_iam_role_policy_attachment" "hachiko-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.hachiko-node.name
}

resource "aws_iam_instance_profile" "hachiko-node" {
  name = "terraform-eks-hachiko"
  role = aws_iam_role.hachiko-node.name
}