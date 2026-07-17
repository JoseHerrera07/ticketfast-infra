output "lambda_recepcion_arn" {
  description = "ARN de la Lambda de recepcion"
  value       = aws_lambda_function.recepcion.arn
}

output "lambda_recepcion_invoke_arn" {
  description = "Invoke ARN de la Lambda de recepcion, usado por el modulo api para la integracion con API Gateway"
  value       = aws_lambda_function.recepcion.invoke_arn
}

output "lambda_recepcion_function_name" {
  description = "Nombre de la funcion de recepcion"
  value       = aws_lambda_function.recepcion.function_name
}

output "lambda_procesamiento_arn" {
  description = "ARN de la Lambda de procesamiento"
  value       = aws_lambda_function.procesamiento.arn
}
output "lambda_procesamiento_function_name" {
  description = "Nombre de la funcion de procesamiento"
  value       = aws_lambda_function.procesamiento.function_name
}
