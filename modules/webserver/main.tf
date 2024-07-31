
resource "aws_key_pair" "key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}

data "aws_ami" "my-ami" {
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
    Name = "ami-${var.env_prefix}"
  }

}

resource "aws_security_group" "sgp" {
  name   = "sec-grp"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgp-${var.env_prefix}"
  }
}

resource "aws_instance" "ec2-instance" {
  ami                         = data.aws_ami.my-ami.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.sgp.id]
  availability_zone           = var.availability_zone_1
  subnet_id                   = var.pub_subnet_id_1
  key_name                    = aws_key_pair.key.key_name
  associate_public_ip_address = true

  tags = {
    Name = "ec2-${var.env_prefix}"
  }
}

resource "aws_ebs_volume" "ebs" {
  availability_zone = var.availability_zone_1
  size              = 3

  tags = {
    Name = "ebs-${var.env_prefix}"
  }
}

resource "aws_volume_attachment" "ec2-ebs-attachment" {
  device_name = "/dev/xvdh"
  instance_id = aws_instance.ec2-instance.id
  volume_id   = aws_ebs_volume.ebs.id
}

