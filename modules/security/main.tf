data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# --- Rol de la Lambda de recepción: solo logs + enviar mensajes a SQS ---
resource "aws_iam_role" "lambda_recepcion" {
  name               = "${var.name_prefix}-lambda-recepcion-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_recepcion_basic" {
  role       = aws_iam_role.lambda_recepcion.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_recepcion_sqs" {
  name = "${var.name_prefix}-lambda-recepcion-sqs-policy"
  role = aws_iam_role.lambda_recepcion.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = var.queue_arn
      }
    ]
  })
}

# --- Rol de la Lambda de procesamiento: logs + leer/borrar de SQS + escribir en DynamoDB + enviar correo por SES ---
resource "aws_iam_role" "lambda_procesamiento" {
  name               = "${var.name_prefix}-lambda-procesamiento-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.common_tags
}

resource "aws_iam_role_policy_attachment" "lambda_procesamiento_basic" {
  role       = aws_iam_role.lambda_procesamiento.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_procesamiento_sqs_dynamodb" {
  name = "${var.name_prefix}-lambda-procesamiento-sqs-dynamodb-policy"
  role = aws_iam_role.lambda_procesamiento.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.queue_arn
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:PutItem"]
        Resource = var.table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_procesamiento_ses" {
  name = "${var.name_prefix}-lambda-procesamiento-ses-policy"
  role = aws_iam_role.lambda_procesamiento.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ses:FromAddress" = var.ses_sender_email
          }
        }
      }
    ]
  })
}
