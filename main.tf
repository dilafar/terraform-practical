provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}

resource "aws_vpc" "dev-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name : "vpc_dev"
  }

}

resource "aws_subnet" "dev-subnet" {
  vpc_id            = aws_vpc.dev-vpc.id
  availability_zone = var.availability_zone
  cidr_block        = var.subnet_cidr_block

  tags = {
    Name : "subnet_dev"
  }

}

output "dev-vpc-id" {
  value = aws_vpc.dev-vpc.id
}

