terraform {
  required_version = ">= 1.7.0"

  # Estado remoto: evita que el state viva solo en la máquina local.
  # El bucket y la tabla de locking se crean UNA VEZ, fuera de este mismo
  # código (no se puede crear con Terraform el backend que Terraform va a usar
  # para guardarse a sí mismo). Ver README.md, sección "Bootstrap del backend".
  backend "s3" {
    bucket         = "ticketfast-terraform-state"
    key            = "ticketfast/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "ticketfast-terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# NOTA sobre ambientes:
# No usamos variables aquí porque el bloque "backend" no admite interpolación.
# En su lugar usamos Terraform Workspaces (terraform workspace new dev/staging/prod).
# El backend S3 organiza automáticamente el state de cada workspace bajo
# la ruta env:/<workspace>/<key>, así que dev, staging y prod nunca se pisan
# entre sí aunque compartan este mismo backend.tf.
