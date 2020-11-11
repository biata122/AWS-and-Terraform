
terraform {
  required_version = ">= 0.12.26"
    backend "s3" {
    bucket = "terraform-state-by-biata"
    key    = "s3/terraform"
    region ="us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}


module "mymodule" {

  source = "../modules"
  name = "module-hw3"

  vpc_cidr="10.0.0.0/16"
  zones=["us-east-1a", "us-east-1b"]
  public_subnets=["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets=["10.0.3.0/24", "10.0.4.0/24"]
  route_tables_names=["public", "private-a", "private-b"]
  enable_dns_hostnames=true
  vpc=true


}