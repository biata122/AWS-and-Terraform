variable "aws_region" {
  description = "the AWS region"
  type        = string
  default     = ""
}

variable "zones" {
  description = "for multi zone deployment"
  type        = list(string)
  default     = []
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "0.0.0.0/0"

}
variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC"
  default     = "default"

}
variable "enable_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC"
  type        = bool
  default     = false
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []

}
variable "vpc" {
  description = "Boolean if the EIP is in a VPC or not"
  type        = bool
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address"
  type        = bool
  default     = true
}

variable "route_tables_names" {
  description = "The route tables names"
  type        = list(string)
  default     = []
}

variable "name" {
  description = "for resource usage"
  type        = string
  default     = ""
}
