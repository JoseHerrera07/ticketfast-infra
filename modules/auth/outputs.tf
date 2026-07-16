output "user_pool_id" {
  description = "ID del User Pool de Cognito, usado por el modulo api para el authorizer"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "ARN del User Pool de Cognito"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_client_id" {
  description = "ID del cliente de app, usado por el frontend para autenticar usuarios"
  value       = aws_cognito_user_pool_client.web.id
}
