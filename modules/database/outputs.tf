output "table_name" {
  description = "Nombre de la tabla DynamoDB de boletos"
  value       = aws_dynamodb_table.tickets.name
}

output "table_arn" {
  description = "ARN de la tabla, usado por el módulo security para dar permisos de escritura a las Lambdas"
  value       = aws_dynamodb_table.tickets.arn
}
