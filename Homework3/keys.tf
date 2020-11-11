  
resource "tls_private_key" "hw3_key_biata" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "hw3_key_biata" {
  key_name   = "hw3-key-biata"
  public_key = tls_private_key.hw3_key_biata.public_key_openssh
  
}

resource "local_file" "hw3_key_biata" {
  sensitive_content  = tls_private_key.hw3_key_biata.private_key_pem
  filename           = "hw3_key_biata.pem"
}