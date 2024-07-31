module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name            = var.vpc_name
  cidr            = var.vpc_cidr_block
  public_subnets  = var.public_cidr_blocks
  private_subnets = var.private_cidr_blocks
  azs             = data.aws_availability_zones.zones.names

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Environment                                 = "${var.env_prefix}"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = 1
  }

}