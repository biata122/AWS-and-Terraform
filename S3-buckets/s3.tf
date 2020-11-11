terraform {
  required_version = ">= 0.12.26"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-state-by-biata"
  versioning {
    enabled = true
  }
  tags = {
    Name  = "state bucket"
  }
}

