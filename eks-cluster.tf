module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.20.0"

  cluster_name                   = var.cluster_name
  cluster_version                = "1.30"
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true


  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    one = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.small"]
      name           = "node-group-1"
      min_size       = 2
      max_size       = 4
      desired_size   = 2
    },
    two = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.small"]
      name           = "node-group-2"
      min_size       = 2
      max_size       = 4
      desired_size   = 2
    }
  }


  tags = {
    Environment = "${var.env_prefix}"
  }

}