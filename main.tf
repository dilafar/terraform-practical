provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.env_prefix}"
  }
}

module "my-subnet" {
  source              = "./modules/subnet"
  vpc_id              = aws_vpc.my-vpc.id
  public_cidr_blocks  = var.public_cidr_blocks
  availability_zone_1 = var.availability_zone_1
  availability_zone_2 = var.availability_zone_2
  availability_zone_3 = var.availability_zone_3
  env_prefix          = var.env_prefix
  private_cidr_blocks = var.private_cidr_blocks
}
module "webserver" {
  source              = "./modules/webserver"
  public_key_location = var.public_key_location
  env_prefix          = var.env_prefix
  vpc_id              = aws_vpc.my-vpc.id
  my_ip               = var.my_ip
  instance_type       = var.instance_type
  availability_zone_1 = var.availability_zone_1
  pub_subnet_id_1     = module.my-subnet.subnet.id
}
