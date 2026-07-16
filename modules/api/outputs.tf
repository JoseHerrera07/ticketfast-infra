output "api_endpoint" {
  description = "URL base del API Gateway, para probar el endpoint POST /compras"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "api_id" {
  description = "ID del API Gateway"
  value       = aws_apigatewayv2_api.main.id
}
