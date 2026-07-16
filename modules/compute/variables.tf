variable "name_prefix" {
  description = "Prefijo de nombres, ej. ticketfast-dev"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
}

variable "lambda_memory_mb" {
  description = "Memoria asignada a ambas Lambdas"
  type        = number
}

variable "lambda_timeout_seconds" {
  description = "Timeout de ambas Lambdas, en segundos"
  type        = number
  default     = 30
}

variable "lambda_recepcion_role_arn" {
  description = "ARN del rol IAM para la Lambda de recepcion (viene del modulo security)"
  type        = string
}

variable "lambda_procesamiento_role_arn" {
  description = "ARN del rol IAM para la Lambda de procesamiento (viene del modulo security)"
  type        = string
}

variable "queue_url" {
  description = "URL de la cola SQS de compras (viene del modulo queue)"
  type        = string
}

variable "queue_arn" {
  description = "ARN de la cola SQS de compras (viene del modulo queue, para el event source mapping)"
  type        = string
}

variable "table_name" {
  description = "Nombre de la tabla DynamoDB de tickets (viene del modulo database)"
  type        = string
}

variable "ses_sender_email" {
  description = "Correo verificado en SES desde el cual se envian las confirmaciones"
  type        = string
}
