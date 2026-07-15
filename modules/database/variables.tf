variable "name_prefix" {
  description = "Prefijo de nombre (ej. ticketfast-dev), viene de la raíz del proyecto"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
}

variable "billing_mode" {
  description = "PAY_PER_REQUEST (recomendado) o PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "environment" {
  description = "Ambiente actual (dev, staging, prod). Controla si se activa deletion_protection."
  type        = string
}
