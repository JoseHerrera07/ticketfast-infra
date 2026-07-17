output "queue_url" {
  description = "URL de la cola principal de compras (la usa la Lambda de recepción para enviar mensajes)"
  value       = aws_sqs_queue.purchases.id
}

output "queue_arn" {
  description = "ARN de la cola principal (lo usa el módulo security para dar permisos, y compute para el event source mapping de la Lambda de procesamiento)"
  value       = aws_sqs_queue.purchases.arn
}

output "dlq_url" {
  description = "URL de la Dead Letter Queue"
  value       = aws_sqs_queue.dlq.id
}

output "dlq_arn" {
  description = "ARN de la Dead Letter Queue"
  value       = aws_sqs_queue.dlq.arn
}
output "dlq_name" {
  description = "Nombre de la Dead Letter Queue, usado por el modulo monitoring para la alarma de CloudWatch"
  value       = aws_sqs_queue.dlq.name
}
