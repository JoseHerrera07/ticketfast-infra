variable "name_prefix" {
  description = "Prefijo de nombre (ej. ticketfast-dev), viene de la raíz del proyecto"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
}

variable "lambda_timeout_seconds" {
  description = "Timeout configurado en la Lambda de procesamiento. Se usa para calcular el visibility_timeout de la cola (debe ser >= 6x este valor, regla de AWS)."
  type        = number
  default     = 30
}
