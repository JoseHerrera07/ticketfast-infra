environment      = "dev"
aws_region       = "us-east-1"
project_name     = "ticketfast"
lambda_memory_mb = 128

# Cambia esto por tu correo real antes de aplicar
alert_email = "admin-dev@ticketfast.example.com"

# cloudflare_api_token, cloudflare_account_id y cloudflare_zone_id
# NO van aquí: son secretos y se pasan por variables de entorno
# (TF_VAR_cloudflare_api_token, etc.) o por GitHub Secrets en el pipeline.
