variable "name_prefix" {
  description = "Prefijo de nombres, ej. ticketfast-dev"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
}

variable "queue_arn" {
  description = "ARN de la cola SQS de compras (viene del módulo queue)"
  type        = string
}

variable "table_arn" {
  description = "ARN de la tabla DynamoDB de tickets (viene del módulo database)"
  type        = string
}

variable "ses_sender_email" {
  description = "Correo verificado en SES desde el cual se envían las notificaciones"
  type        = string
}
