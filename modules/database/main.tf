resource "aws_dynamodb_table" "tickets" {
  name         = "${var.name_prefix}-tickets"
  billing_mode = var.billing_mode

  # Clave compuesta: permite que la Lambda de procesamiento use
  # ConditionExpression = "attribute_not_exists(seat_id)" al reservar
  # un asiento. Si dos compradores intentan el mismo asiento al mismo
  # tiempo, DynamoDB acepta solo la primera escritura y rechaza la
  # segunda de forma atómica (sin locks manuales).
  hash_key  = "event_id"
  range_key = "seat_id"

  attribute {
    name = "event_id"
    type = "S"
  }

  attribute {
    name = "seat_id"
    type = "S"
  }

  # Atributo adicional necesario para el índice secundario (GSI).
  # Los demás atributos (status, purchase_timestamp, ticket_id, etc.)
  # no se declaran aquí: DynamoDB no requiere definir el esquema
  # completo por adelantado, solo las claves primarias y las de los índices.
  attribute {
    name = "user_id"
    type = "S"
  }

  # Permite consultar "mis boletos" por usuario sin escanear toda la tabla.
  global_secondary_index {
    name            = "user_id-index"
    hash_key        = "user_id"
    projection_type = "ALL"
  }

  # RNF 6: RPO <= 1 minuto. Point-in-Time Recovery da recuperación
  # continua a nivel de segundos (mucho mejor que backups periódicos).
  point_in_time_recovery {
    enabled = true
  }

  # Cifrado en reposo (parte del atributo de calidad "Seguridad").
  server_side_encryption {
    enabled = true
  }

  # En prod, evita que un "terraform destroy" accidental borre la tabla real.
  deletion_protection_enabled = var.environment == "prod" ? true : false

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-tickets"
  })
}
