data "archive_file" "recepcion" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/recepcion"
  output_path = "${path.module}/../../lambdas/recepcion.zip"
  excludes    = ["node_modules", "index.test.js"]
}

data "archive_file" "procesamiento" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/procesamiento"
  output_path = "${path.module}/../../lambdas/procesamiento.zip"
  excludes    = ["node_modules", "index.test.js"]
}

resource "aws_lambda_function" "recepcion" {
  function_name    = "${var.name_prefix}-recepcion"
  role             = var.lambda_recepcion_role_arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = var.lambda_memory_mb
  timeout          = var.lambda_timeout_seconds
  filename         = data.archive_file.recepcion.output_path
  source_code_hash = data.archive_file.recepcion.output_base64sha256
  tags             = var.common_tags

  environment {
    variables = {
      QUEUE_URL = var.queue_url
    }
  }
}

resource "aws_lambda_function" "procesamiento" {
  function_name    = "${var.name_prefix}-procesamiento"
  role             = var.lambda_procesamiento_role_arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  memory_size      = var.lambda_memory_mb
  timeout          = var.lambda_timeout_seconds
  filename         = data.archive_file.procesamiento.output_path
  source_code_hash = data.archive_file.procesamiento.output_base64sha256
  tags             = var.common_tags

  environment {
    variables = {
      TABLE_NAME   = var.table_name
      SENDER_EMAIL = var.ses_sender_email
    }
  }
}

resource "aws_lambda_event_source_mapping" "procesamiento_from_queue" {
  event_source_arn = var.queue_arn
  function_name    = aws_lambda_function.procesamiento.arn
  batch_size       = 1
  enabled          = true
}
