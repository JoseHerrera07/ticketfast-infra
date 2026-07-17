output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB de boletos"
  value       = module.database.table_name
}

output "dynamodb_table_arn" {
  description = "ARN de la tabla DynamoDB de boletos"
  value       = module.database.table_arn
}

output "queue_url" {
  description = "URL de la cola de compras SQS"
  value       = module.queue.queue_url
}

output "dlq_url" {
  description = "URL de la Dead Letter Queue"
  value       = module.queue.dlq_url
}

output "lambda_recepcion_role_arn" {
  description = "ARN del rol IAM de la Lambda de recepción"
  value       = module.security.lambda_recepcion_role_arn
}

output "lambda_procesamiento_role_arn" {
  description = "ARN del rol IAM de la Lambda de procesamiento"
  value       = module.security.lambda_procesamiento_role_arn
}

output "lambda_recepcion_arn" {
  description = "ARN de la Lambda de recepcion"
  value       = module.compute.lambda_recepcion_arn
}

output "lambda_recepcion_invoke_arn" {
  description = "Invoke ARN de la Lambda de recepcion (para API Gateway)"
  value       = module.compute.lambda_recepcion_invoke_arn
}

output "lambda_procesamiento_arn" {
  description = "ARN de la Lambda de procesamiento"
  value       = module.compute.lambda_procesamiento_arn
}

output "api_endpoint" {
  description = "URL base del API Gateway para probar POST /compras"
  value       = module.api.api_endpoint
}

output "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  value       = module.auth.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "ID del User Pool Client de Cognito, usado por el frontend"
  value       = module.auth.user_pool_client_id
}

output "sns_topic_arn" {
  description = "ARN del topico SNS de alertas"
  value       = module.notifications.sns_topic_arn
}

output "vpc_id" {
  description = "ID de la VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "ID de la subred publica"
  value       = module.networking.public_subnet_id
}

output "monitoring_sg_id" {
  description = "ID del security group de monitoreo"
  value       = module.networking.monitoring_sg_id
}
