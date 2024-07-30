provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}

resource "aws_vpc" "dev-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.env_prefix}-vpc"
  }

}

resource "aws_subnet" "dev-subnet" {
  vpc_id            = aws_vpc.dev-vpc.id
  availability_zone = var.availability_zone
  cidr_block        = var.subnet_cidr_block

  tags = {
    Name = "${var.env_prefix}-subnet"
  }

}

resource "aws_internet_gateway" "dev-gateway" {
  vpc_id = aws_vpc.dev-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_route_table" "dev-route" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gateway.id
  }

  tags = {
    Name = "${var.env_prefix}-route_table"
  }
}

resource "aws_route_table_association" "route-association-dev" {
  route_table_id = aws_route_table.dev-route.id
  subnet_id      = aws_subnet.dev-subnet.id
}

output "dev-vpc-id" {
  value = aws_vpc.dev-vpc.id
}

