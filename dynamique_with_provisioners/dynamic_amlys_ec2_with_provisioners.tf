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
resource "aws_instance" "ec2withprovisioner" {
  ami                    = data.aws_ami.app_ami.id
  instance_type          = var.instancetype # on a variabilisé dans le fichier tfvars
  key_name               = "ec2-iam-amlys"
  tags                   = var.aws_common_tag
  vpc_security_group_ids = [aws_security_group.allow_http_https.id]

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras install -y nginx1.12",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./ec2-iam-amlys-key.pem")
      host        = self.public_ip
    }
  }

  # connection {
  #   type        = "ssh"
  #   user        = "ec2-user"
  #   private_key = file("${path.module}/ec2-iam-amlys-key.pem")
  #   host        = aws_instance.ec2withprovisioner.public_ip
  # }
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

  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #autoriser tout le monde
  }

  egress {
    description = "go out to internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # ça veut dire on prend tout
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# on crée une eip car on a pas envie que aws crée lui même l'ip de notre instance directement et donc le mieux est de la gérer séparément
# comme ça on pourra virer la machine mais garder l'ip
resource "aws_eip" "lb" {
  instance = aws_instance.ec2withprovisioner.id
  domain   = "vpc"

  # on le met ici car on a besoin de l'ip public créée par le eip et pour pour cela il a besoin déjà de notre instance donc il faut le faire ici
  provisioner "local-exec" {
    command = "echo PUBLIC IP: ${self.public_ip}; ID: ${aws_instance.ec2withprovisioner.id}; AZ: ${aws_instance.ec2withprovisioner.availability_zone} > infos_ec2.txt"
  }
}