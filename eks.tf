module "eks-wordpress" {
    source              = "terraform-aws-modules/eks/aws"
    cluster_name        = var.eks_cluster_name
    cluster_version     = "1.15"
    subnets             = module.vpc.public_subnets
    vpc_id              = module.vpc.vpc_id

    worker_groups       = [
        {
            instance_type           = var.eks_instance_type
            asg_max_size            = var.eks_asg_max_size
            asg_desired_capacity    = var.asg_desired_capacity
        }
    ]
}