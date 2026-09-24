output "vpc_id" {
  description = "ID da VPC do DevOps Lab"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID da subnet pública"
  value       = aws_subnet.public.id
}

output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.web.id
}

output "instance_private_ip" {
  description = "IP privado da instância EC2"
  value       = aws_instance.web.private_ip
}

output "instance_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.web.public_dns
}
