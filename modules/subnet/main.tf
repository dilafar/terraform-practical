resource "aws_subnet" "dev-subnet" {
  vpc_id            = var.vpc_id
  availability_zone = var.availability_zone
  cidr_block        = var.subnet_cidr_block

  tags = {
    Name = "${var.env_prefix}-subnet"
  }

}

resource "aws_internet_gateway" "dev-gateway" {
  vpc_id = var.vpc_id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "dev-route" {
  default_route_table_id = var.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gateway.id
  }

  tags = {
    Name = "${var.env_prefix}-main-route_table"
  }
}
