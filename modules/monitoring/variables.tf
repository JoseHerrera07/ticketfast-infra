variable "name_prefix" {
  description = "Prefijo de nombres, ej. ticketfast-dev"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
}

variable "vpc_id" {
  description = "ID de la VPC (viene del modulo networking)"
  type        = string
}

variable "public_subnet_id" {
  description = "ID de la subred publica donde vive el EC2 de monitoreo"
  type        = string
}

variable "monitoring_sg_id" {
  description = "ID del security group para el EC2 de monitoreo"
  type        = string
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para monitoreo"
  type        = string
  default     = "t3.micro"
}

variable "sns_topic_arn" {
  description = "ARN del topico SNS de alertas (viene del modulo notifications)"
  type        = string
}

variable "dlq_name" {
  description = "Nombre de la Dead Letter Queue, para la alarma de mensajes acumulados"
  type        = string
}

variable "lambda_procesamiento_function_name" {
  description = "Nombre de la Lambda de procesamiento, para la alarma de errores"
  type        = string
}
