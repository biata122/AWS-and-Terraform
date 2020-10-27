##################################################################################
# VARIABLES
##################################################################################

#variable "aws_access_key" {}
#variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  default = "us-east-1"
}
variable "instance_count" {
  default = 2
}

##################################################################################
# LOCALS
##################################################################################

locals {
  common_tags = {
    purpose  = "exercise"
    owner    = "biata"
  }
 }

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
 # access_key = var.aws_access_key
 #secret_key = var.aws_secret_key
  region   = var.region
  shared_credentials_file = "C:\\Users\\biata\\.aws\\credentials"
 # profile  = "default"
  
}

##################################################################################
# DATA
##################################################################################

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#to get the default EBS encryption KMS key in the current region
data "aws_ebs_default_kms_key" "current" {}

##################################################################################
# RESOURCES
##################################################################################

#This uses the default VPC.  It WILL NOT delete it on destroy.
resource "aws_default_vpc" "default" {

}

resource "aws_security_group" "allow_ssh_http" {
  name        = "nginx_demo"
  description = "Allow ports 80 and 22 for nginx demo"
  vpc_id      = aws_default_vpc.default.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  count                  = var.instance_count
  ami                    = data.aws_ami.aws-linux.id
  availability_zone      = "${var.region}a"
  instance_type          = "t2.medium"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]
  tags = merge(local.common_tags, { Name = "nginx-${count.index}" })

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }

  root_block_device {
    delete_on_termination = true
    volume_type = "gp2"
    volume_size = "10"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    volume_type = "gp2"
    volume_size = "10"
    encrypted = true
    kms_key_id = data.aws_ebs_default_kms_key.current.key_arn
    delete_on_termination = true
  }

  # We run a remote provisioner on the instance after creating it.
  # In this case, we just install nginx and start it. 
   provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
      "echo '<html><head><title>OpsSchool Rules</title></head><body style=\"background-color:#ccffff\"><p style=\"text-align: center;\"><span style=\"color:#404040;\"><span style=\"font-size:28px;\">OpsSchool Ruls</span></span></p></body></html>' | sudo tee /usr/share/nginx/html/index.html"
    ]
  }
}

##################################################################################
# OUTPUT
##################################################################################
#return all dns 
output "aws_instance_public_dns" {
  value = aws_instance.nginx.*.public_dns
}
