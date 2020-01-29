# Terraform EKS

module "eks" {
  source            = "terraform-aws-modules/eks/aws"
  cluster_name      = "expresscart-eks"
  cluster_version   = "1.14"
  subnets           = module.vpc.private_subnets
  vpc_id            = module.vpc.vpc_id
  workers_role_name = "expresscart-eks-hachiko-node"

  worker_groups = [
    {
      instance_type = "t3.micro"
      asg_max_size  = 3
    }
  ]
}