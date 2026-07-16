output "sns_topic_arn" {
  description = "ARN del topico SNS de alertas, usado por el modulo monitoring para las alarmas de CloudWatch"
  value       = aws_sns_topic.alerts.arn
}

output "ses_identity_arn" {
  description = "ARN de la identidad SES verificada"
  value       = aws_ses_email_identity.sender.arn
}
