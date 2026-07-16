output "lambda_recepcion_role_arn" {
  description = "ARN del rol IAM para la Lambda de recepción"
  value       = aws_iam_role.lambda_recepcion.arn
}

output "lambda_procesamiento_role_arn" {
  description = "ARN del rol IAM para la Lambda de procesamiento"
  value       = aws_iam_role.lambda_procesamiento.arn
}
