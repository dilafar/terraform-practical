
resource "aws_security_group" "master-sg" {
  name        = "master-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }


  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 10250
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 4240
    to_port     = 4240
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "master-sg-dev"
  }

}

resource "aws_security_group" "worker-sg" {
  name        = "worker-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 4240
    to_port     = 4240
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "worker-sg-dev"
  }

}



/*data "aws_ami" "dev-ami" {
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

}*/

resource "aws_key_pair" "dev-key" {
  key_name   = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "k8-master" {
  ami                         = "ami-03e31863b8e1f70a5"
  instance_type               = var.instance_type_master
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.master-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true

  #user_data = file("script.sh")
  #add master-slave tag to additional master node
  
  tags = {
    Name = "master-node"
    Node = "master-controller"
    Cluster = "k8-kubeadm"
  }

}

resource "aws_instance" "k8-worker_1" {
  ami                         = "ami-03e31863b8e1f70a5"
  instance_type               = var.instance_type_worker
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.worker-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true

  #user_data = file("script.sh")
  
  tags = {
    Name = "worker-node-1"
    Node = "worker"
    Cluster = "k8-kubeadm"
  }

}


resource "aws_instance" "k8-worker_2" {
  ami                         = "ami-03e31863b8e1f70a5"
  instance_type               = var.instance_type_worker
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.worker-sg.id]
  key_name                    = aws_key_pair.dev-key.key_name
  associate_public_ip_address = true

  #user_data = file("script.sh")
  
  tags = {
    Name = "worker-node-2"
    Node = "worker"
    Cluster = "k8-kubeadm"
  }

}



/*
resource "null_resource" "name" {
  triggers = {
    trigger = aws_instance.dev-instance.public_ip
  }
  provisioner "local-exec" {
    #working_dir = "/mnt/e/terraform-new-practice/terraform-practical"
    command = "ansible-playbook --inventory ${aws_instance.dev-instance.public_ip}, --private-key /home/fadhil/.ssh/id_rsa --user ubuntu  install-docker.yaml"
    }
}
*/
