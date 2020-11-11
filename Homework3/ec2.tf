

resource "aws_instance" "web" {
  count                  = length(module.mymodule.public_subnet_id)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  user_data              = file("web.sh")
  subnet_id              = module.mymodule.public_subnet_id[count.index]
  vpc_security_group_ids = [module.mymodule.security_group_allow_ssh_http]
  key_name               = aws_key_pair.hw3_key_biata.key_name
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  associate_public_ip_address = true

  tags = {
    Name = "web-${count.index}"
  }

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ubuntu"
    private_key = file(var.private_key_path)
  }


}

resource "aws_instance" "db" {
  count                  = length(module.mymodule.public_subnet_id)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = module.mymodule.private_subnet_id[count.index]
  vpc_security_group_ids = [module.mymodule.security_group_allow_ssh]
  key_name               = aws_key_pair.hw3_key_biata.key_name
  
  tags = {
    Name = "db-${count.index}"
  }
}

resource "aws_iam_role" "iam_role_ec2" {
  name = var.role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
tags = {tag-key = "ec2-role"}
}


resource "aws_iam_role_policy" "s3_to_ec2_write_role" {
  name = var.s3_policy_name
  role = aws_iam_role.iam_role_ec2.name

   policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::web-log-by-biata",
                "arn:aws:s3:::web-log-by-biata/*"
            ]
    }
  ]
}
EOF
}


resource "aws_iam_instance_profile" "instance_profile" {
  name = "ec2_iam_role_instance_profile"
  role = aws_iam_role.iam_role_ec2.name
}

