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
