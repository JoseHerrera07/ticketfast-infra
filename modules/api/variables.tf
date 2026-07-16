variable "name_prefix" {
  description = "Prefijo de nombres, ej. ticketfast-dev"
  type        = string
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
}

variable "lambda_recepcion_arn" {
  description = "ARN de la Lambda de recepcion (viene del modulo compute)"
  type        = string
}

variable "lambda_recepcion_invoke_arn" {
  description = "Invoke ARN de la Lambda de recepcion, usado por la integracion de API Gateway"
  type        = string
}

variable "lambda_recepcion_function_name" {
  description = "Nombre de la funcion de recepcion, usado por el permiso de invocacion"
  type        = string
}

variable "cognito_user_pool_client_id" {
  description = "ID del User Pool Client de Cognito, usado por el authorizer JWT"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "ID del User Pool de Cognito"
  type        = string
}

variable "aws_region" {
  description = "Region de AWS, usada para construir la URL del issuer de Cognito"
  type        = string
}
