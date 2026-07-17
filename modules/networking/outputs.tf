output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID de la subred publica, usada por el modulo monitoring para el EC2/ASG"
  value       = aws_subnet.public.id
}

output "monitoring_sg_id" {
  description = "ID del security group del EC2 de monitoreo"
  value       = aws_security_group.monitoring.id
}
