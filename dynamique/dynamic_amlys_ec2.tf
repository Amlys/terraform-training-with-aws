provider "aws" {
  region     = "us-east-1"
  access_key = "__IAM_USER_ACCESS_KEY__"
  secret_key = "__IAM_USER_SECRET_KEY__"
}

# Là on fournit les données de notre ami, un peu comme image docker
data "aws_ami" "app_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

# et là on déclare notre instance, container docker
resource "aws_instance" "mydynamicec2" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instancetype # on a variabilisé dans le fichier tfvars
  key_name               = "ec2-iam-amlys"
  tags                   = var.aws_common_tag
  vpc_security_group_ids = [aws_security_group.allow_http_https.id]
}

resource "aws_security_group" "allow_http_https" {
  name        = "amlys-sg"
  description = "allow http and https inbound traffic"

  ingress {
    description = "tls from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #autoriser tout le monde
  }
  ingress {
    description = "http from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #autoriser tout le monde
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.mydynamicec2.id
  domain   = "vpc"
}