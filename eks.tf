# Terraform EKS

module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = "expresscart-eks"
  cluster_version   = "1.14"
  subnets           = module.vpc.public_subnets
  vpc_id            = module.vpc.vpc_id
  workers_role_name = aws_iam_role.hachiko-node.name

  worker_groups = [
    {
      instance_type = "t2.medium"
      asg_max_size  = 5
    }
  ]
}