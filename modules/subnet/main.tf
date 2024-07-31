
resource "aws_subnet" "pubsub-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_cidr_blocks[0]
  availability_zone = var.availability_zone_1
  tags = {
    Name = "pubsub-1-${var.env_prefix}"
  }
}

resource "aws_subnet" "pubsub-2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_cidr_blocks[1]
  availability_zone = var.availability_zone_2
  tags = {
    Name = "pubsub-2-${var.env_prefix}"
  }
}

resource "aws_subnet" "pubsub-3" {
  vpc_id            = var.vpc_id
  cidr_block        = var.public_cidr_blocks[2]
  availability_zone = var.availability_zone_3
  tags = {
    Name = "pubsub-3-${var.env_prefix}"
  }
}

resource "aws_subnet" "prisub-1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_cidr_blocks[0]
  availability_zone = var.availability_zone_1
  tags = {
    Name = "prisub-1-${var.env_prefix}"
  }
}

resource "aws_subnet" "prisub-2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_cidr_blocks[1]
  availability_zone = var.availability_zone_2
  tags = {
    Name = "prisub-2-${var.env_prefix}"
  }
}

resource "aws_subnet" "prisub-3" {
  vpc_id            = var.vpc_id
  cidr_block        = var.private_cidr_blocks[2]
  availability_zone = var.availability_zone_3
  tags = {
    Name = "prisub-3-${var.env_prefix}"
  }
}

resource "aws_internet_gateway" "gtw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "gtw-${var.env_prefix}"
  }
}

resource "aws_route_table" "route-table" {
  vpc_id = var.vpc_id

  route {
    gateway_id = aws_internet_gateway.gtw.id
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "rt-${var.env_prefix}"
  }
}

resource "aws_route_table_association" "rt-association-pubsub1" {
  route_table_id = aws_route_table.route-table.id
  subnet_id      = aws_subnet.pubsub-1.id
}

resource "aws_route_table_association" "rt-association-pubsub2" {
  route_table_id = aws_route_table.route-table.id
  subnet_id      = aws_subnet.pubsub-2.id
}

resource "aws_route_table_association" "rt-association-pubsub3" {
  route_table_id = aws_route_table.route-table.id
  subnet_id      = aws_subnet.pubsub-3.id
}
