variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "role_name" {
  type    = string
  default = "ec2-iam-role"
}

variable "s3_policy_name" {
  type    = string
  default = "s3-policy"
}

locals {
  common_tags = {
    purpose = "exercise-3"
    owner   = "biata"
  }
}

