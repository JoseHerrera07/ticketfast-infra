output "key_pair_name" {
  description = "Nombre del key pair de EC2 creado"
  value       = aws_key_pair.monitoring.key_name
}

output "private_key_path" {
  description = "Ruta local del archivo .pem con la llave privada para SSH"
  value       = local_sensitive_file.private_key.filename
}

output "autoscaling_group_name" {
  description = "Nombre del Auto Scaling Group de monitoreo"
  value       = aws_autoscaling_group.monitoring.name
}
