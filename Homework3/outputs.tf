
output "aws_instance_web_public_ip" {
  value = aws_instance.web.*.public_ip
}

output "aws_instance_web_private_ip" {
  value = aws_instance.web.*.private_ip
}

output "aws_instance_db_private_ip" {
  value = aws_instance.db.*.private_ip
}

output "app_load_balancer_dns" {
  value = aws_lb.lb.dns_name
}

