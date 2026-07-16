variable "name_prefix" {
  description = "Prefijo de nombres, ej. ticketfast-dev"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
}

variable "ses_sender_email" {
  description = "Correo remitente a verificar en SES para el envio de confirmaciones de compra"
  type        = string
}

variable "alert_email" {
  description = "Correo del administrador que recibe las alertas de CloudWatch/Grafana via SNS"
  type        = string
}
