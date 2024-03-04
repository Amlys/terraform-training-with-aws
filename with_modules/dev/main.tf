provider "aws" {
  region     = "us-east-1"
  access_key = "__IAM_USER_ACCESS_KEY__"
  secret_key = "__IAM_USER_SECRET_KEY__"
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-amlys"
    key = "amlys-dev.tfstate"
    region = "us-east-1"
    access_key = "__IAM_USER_ACCESS_KEY__"
    secret_key = "__IAM_USER_SECRET_KEY__"
  }
}

module "ec2" {
    # on peut spécifier un repo public de community ou autre
    source = "../modules/ec2_modules"
    instancetype = "t2.nano"
    aws_common_tag = {
      Name = "ec2-dev-amlys"
    }

    sgname = "amlys-dev-sg"
}