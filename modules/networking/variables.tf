variable "name_prefix" {
  description = "Prefijo de nombres, ej. ticketfast-dev"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
}

variable "admin_ip_cidr" {
  description = "CIDR de la IP del administrador, permitida para SSH y Grafana (formato: X.X.X.X/32)"
  type        = string
}
