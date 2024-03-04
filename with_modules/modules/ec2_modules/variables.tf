# ici je défini le type de mon instance
variable "instancetype" {
  type        = string
  description = "set aws instance type with dynamique vars"
  default     = "t2.nano"
}

variable "sgname" {
  type        = string
  description = "set security group name"
  default     = "amlys-sg"
}

variable "aws_common_tag" {
  type        = map(any)
  description = "Set aws tag"
  default = {
    Name = "ec2-dynamique"
  }
}