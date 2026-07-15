output "dynamodb_table_name" {
  description = "Nombre de la tabla DynamoDB de boletos"
  value       = module.database.table_name
}

output "dynamodb_table_arn" {
  description = "ARN de la tabla DynamoDB de boletos"
  value       = module.database.table_arn
}
