variable "aws_region" {
  description = "Región de AWS donde se despliega toda la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto, usado como prefijo en los nombres de recursos"
  type        = string
  default     = "ticketfast"
}

variable "cloudflare_api_token" {
  description = "Token de API de Cloudflare (con permisos de Zone + Pages). Se pasa por variable de entorno TF_VAR_cloudflare_api_token, nunca se hardcodea."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "ID de la cuenta de Cloudflare"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "ID de la zona DNS de Cloudflare para el dominio de Ticketfast"
  type        = string
}

variable "alert_email" {
  description = "Correo del administrador que recibe las alertas de SNS"
  type        = string
}

variable "lambda_memory_mb" {
  description = "Memoria asignada a las Lambdas (afecta CPU y costo). Se ajusta por ambiente en los .tfvars"
  type        = number
  default     = 256
}

variable "dynamodb_billing_mode" {
  description = "Modo de facturación de DynamoDB: PAY_PER_REQUEST (recomendado, escala solo) o PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "environment" {
  description = "Nombre del ambiente. Debe coincidir con el workspace activo (dev, staging o prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment debe ser \"dev\", \"staging\" o \"prod\"."
  }
}
variable "ses_sender_email" {
  description = "Correo verificado en SES desde el cual se envían las notificaciones de compra"
  type        = string
}
