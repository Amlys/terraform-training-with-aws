provider "aws" {
  region     = "us-east-1"
  access_key = "__IAM_USER_ACCESS_KEY__"
  secret_key = "__IAM_USER_SECRET_KEY__"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0440d3b780d96b29d"
  instance_type = "t2.micro"
  key_name      = "ec2-iam-amlys"
  tags = {
    name = "amlys-ec2-terraform"
  }
#   root_block_device {
#     delete_on_termination = true
#     }
}