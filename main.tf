terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Call the VPC module
module "network" {
  source             = "./modules/vpc"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  availability_zone  = "${var.aws_region}a"
}

# Security Group to allow SSH (22) and HTTP (80)
resource "aws_security_group" "web_sg" {
  name   = "web_sg"
  vpc_id = module.network.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.my_key.private_key_pem
  filename        = pathexpand("~/.key")
  file_permission = "0500"

}
# AWS EC2 instance (your web server)
resource "aws_instance" "web_server" {
  ami             = var.ami_id
  instance_type   = "t3.micro"
  subnet_id       = module.network.public_subnet_id
  security_groups = [aws_security_group.web_sg.id]
  key_name        = var.key_name
  user_data       = <<-EOF
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y docker.io python3-pip python3-setuptools
    sudo pip3 install docker
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker ubuntu
  EOF

  tags = {
    Name = "NginxWebServer"
  }
}
