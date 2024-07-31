
resource "aws_security_group" "dev-sg" {
  name        = "dev-security-group"
  description = "Allow ssh traffic from my ip"
  vpc_id      = var.vpc_id

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

data "aws_ami" "dev-ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = [var.ami_name]
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
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.dev-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true

  user_data = file("script.sh")
  
  tags = {
    Name = "${var.env_prefix}-instance"
  }

}

