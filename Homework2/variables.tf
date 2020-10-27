variable "private_key_path" {
default= "C:\\Users\\biata\\key-pair-ec2.pem"
}

variable "key_name" {
  default = "key-pair-ec2"
}

variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "zones" {
  description = "for multi zone deployment"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}


locals {
  common_tags = {
    purpose = "exercise-2"
    owner   = "biata"
  }
}