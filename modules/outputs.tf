
output "vpc_id" {
  description = "vpc id"
  value       = aws_vpc.this.id
}

output "private_subnet_id" {
  description = "bucket name id"
  value       = aws_subnet.private.*.id
}

output "public_subnet_id" {
  description = "Domain name of the bucket"
  value       = aws_subnet.public.*.id
}

output "security_group_allow_ssh_http" {
  description = "Domain name of the bucket"
  value       = aws_security_group.allow_ssh_http.id
}

output "security_group_allow_ssh" {
  description = "Domain name of the bucket"
  value       = aws_security_group.allow_ssh.id
}

output "security_group_allow_http" {
  description = "Domain name of the bucket"
  value       = aws_security_group.allow_http.id
}
