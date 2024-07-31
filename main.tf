provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "zones" {}

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

locals {
  cluster_name = var.cluster_name
}