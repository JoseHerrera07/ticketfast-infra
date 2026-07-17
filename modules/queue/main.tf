# Dead Letter Queue: donde caen los mensajes que fallaron 3 veces seguidas.
# Retención larga (14 días) porque estos mensajes representan compras que
# necesitan revisión manual — no se pueden perder.
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.name_prefix}-purchases-dlq"
  message_retention_seconds = 1209600 # 14 días (máximo permitido por SQS)
  sqs_managed_sse_enabled   = true

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-purchases-dlq"
  })
}

# Cola principal: aquí caen las peticiones de compra que API Gateway
# (vía la Lambda de recepción) va encolando.
resource "aws_sqs_queue" "purchases" {
  name = "${var.name_prefix}-purchases-queue"

  # El visibility timeout debe ser MAYOR al timeout de la Lambda que
  # procesa los mensajes. Si no, SQS puede volver a entregar el mismo
  # mensaje a otra invocación de Lambda mientras la primera todavía
  # lo está procesando, generando compras duplicadas.
  # Regla general de AWS: visibility_timeout >= 6 * lambda_timeout.
  visibility_timeout_seconds = var.lambda_timeout_seconds * 6

  message_retention_seconds = 345600 # 4 días
  sqs_managed_sse_enabled   = true

  # Redrive policy: tras 3 intentos fallidos, el mensaje se mueve a la DLQ
  # en vez de reintentarse indefinidamente. Esto es lo que cumple el RNF 3
  # (retención de peticiones sin pérdida, aunque no procesamiento inmediato).
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-purchases-queue"
  })
}

# Política de redrive-allow: le dice explícitamente a SQS que esta DLQ
# solo puede recibir mensajes redirigidos desde la cola "purchases" de
# arriba (buena práctica de seguridad, evita que cualquier otra cola use
# esta DLQ por error).
resource "aws_sqs_queue_redrive_allow_policy" "dlq_allow" {
  queue_url = aws_sqs_queue.dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.purchases.arn]
  })
}
