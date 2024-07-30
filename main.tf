provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "private_key_location" {}
variable "public_key_location" {}
variable "instance_type" {}

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

resource "aws_default_route_table" "dev-route" {
  default_route_table_id = aws_vpc.dev-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-gateway.id
  }

  tags = {
    Name = "${var.env_prefix}-main-route_table"
  }
}


resource "aws_security_group" "dev-sg" {
  name        = "dev-security-group"
  description = "Allow ssh traffic from my ip"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }

}

/*
resource "aws_default_security_group" "dev-sg" {
  name        = "dev-default-security-group"
  description = "Allow ssh traffic from my ip"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}-default-sg"
  }

}

*/
data "aws_ami" "dev-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  tags = {
    Name = "${var.env_prefix}-ami"
  }

}

resource "aws_key_pair" "dev-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "dev-instance" {
  ami                         = data.aws_ami.dev-ami.id
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = aws_subnet.dev-subnet.id
  vpc_security_group_ids      = [aws_security_group.dev-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true

  /* user_data = <<EOF
                #!/bin/bash
                sudo yum update -y && sudo yum install docker -y
                sudo systemctl start docker 
                sudo usermod -aG docker ec2-user
                docker run -p 8080:80 nginx
                EOF
*/

  // user_data = file("script.sh")
  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source = "script.sh"
    destination = "/home/ec2-user/entry-script.sh"
  }

  provisioner "remote-exec" {
    script = file("entry-script.sh")
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > output.txt"
  }

  tags = {
    Name = "${var.env_prefix}-instance"
  }

}

output "ami-id" {
  value = data.aws_ami.dev-ami
}

output "public-ip" {
  value = aws_instance.dev-instance.public_ip
}


