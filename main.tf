locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "database" {
  source       = "./modules/database"
  name_prefix  = local.name_prefix
  common_tags  = local.common_tags
  environment  = var.environment
  billing_mode = var.dynamodb_billing_mode
}

module "queue" {
  source                 = "./modules/queue"
  name_prefix             = local.name_prefix
  common_tags             = local.common_tags
  lambda_timeout_seconds  = 30
}

module "security" {
  source           = "./modules/security"
  name_prefix      = local.name_prefix
  common_tags      = local.common_tags
  queue_arn        = module.queue.queue_arn
  table_arn        = module.database.table_arn
  ses_sender_email = var.ses_sender_email
}

module "compute" {
  source                         = "./modules/compute"
  name_prefix                    = local.name_prefix
  common_tags                    = local.common_tags
  lambda_memory_mb               = var.lambda_memory_mb
  lambda_recepcion_role_arn      = module.security.lambda_recepcion_role_arn
  lambda_procesamiento_role_arn  = module.security.lambda_procesamiento_role_arn
  queue_url                      = module.queue.queue_url
  queue_arn                      = module.queue.queue_arn
  table_name                     = module.database.table_name
  ses_sender_email                = var.ses_sender_email
}

module "auth" {
  source      = "./modules/auth"
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}
module "api" {
  source                          = "./modules/api"
  name_prefix                     = local.name_prefix
  common_tags                     = local.common_tags
  aws_region                      = var.aws_region
  lambda_recepcion_arn            = module.compute.lambda_recepcion_arn
  lambda_recepcion_invoke_arn     = module.compute.lambda_recepcion_invoke_arn
  lambda_recepcion_function_name  = module.compute.lambda_recepcion_function_name
  cognito_user_pool_id            = module.auth.user_pool_id
  cognito_user_pool_client_id     = module.auth.user_pool_client_id
}

module "notifications" {
  source            = "./modules/notifications"
  name_prefix       = local.name_prefix
  common_tags       = local.common_tags
  ses_sender_email  = var.ses_sender_email
  alert_email       = var.alert_email
}
