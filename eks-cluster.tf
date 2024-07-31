provider "kubernetes" {
  host                   = data.aws_eks_cluster.my-cluster-dev.endpoint
  token                  = data.aws_eks_cluster_auth.my-cluster-dev-auth.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.my-cluster-dev.certificate_authority[0].data)
}

data "aws_eks_cluster" "my-cluster-dev" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "my-cluster-dev-auth" {
  name = module.eks.cluster_id
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.20.0"

  cluster_name                   = "my-eks-cluster"
  cluster_version                = "1.30"
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true


  self_managed_node_group_defaults = {
    instance_type = "t2.micro"
  }

  self_managed_node_groups = {
    one = {
      instance_type = "t2.small"
      name          = "node-group-1"
      min_size      = 2
      max_size      = 4
      desired_size  = 2
    },
    two = {
      instance_type = "t2.small"
      name          = "node-group-2"
      min_size      = 2
      max_size      = 4
      desired_size  = 2
    }
  }

  tags = {
    Environment = "${var.env_prefix}"
  }


}