# Ticketfast — Infraestructura como Código

Infraestructura serverless en AWS para la plataforma de venta de entradas Ticketfast, gestionada con Terraform (aprovisionamiento) y Ansible (configuración del EC2 de monitoreo).

## Estructura del repositorio

```
environments/    Variables por ambiente (dev, staging, prod)
modules/         Un módulo de Terraform por cada capa del diagrama de arquitectura
lambdas/         Código Node.js de las Lambdas + sus pruebas unitarias (Jest)
tests/negocio/   Pruebas de negocio end-to-end
.github/workflows/  Pipeline de CI/CD
```

## Bootstrap del backend remoto (se hace UNA sola vez, manualmente)

Terraform necesita un bucket S3 y una tabla DynamoDB para guardar su *state* de forma remota (ver `backend.tf`). Como Terraform no puede crear la infraestructura que él mismo va a usar para guardarse, este paso se hace a mano una única vez, antes de correr `terraform init` por primera vez:

```bash
aws s3api create-bucket --bucket ticketfast-terraform-state --region us-east-1
aws s3api put-bucket-versioning --bucket ticketfast-terraform-state \
  --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket ticketfast-terraform-state \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws dynamodb create-table \
  --table-name ticketfast-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

## Uso normal (día a día)

```bash
terraform init

# Crear/seleccionar el workspace del ambiente en el que vas a trabajar
terraform workspace new dev        # solo la primera vez
terraform workspace select dev

terraform plan  -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

Para staging o prod, se repite lo mismo cambiando `dev` por `staging` o `prod` en ambos lugares (workspace y `-var-file`).

## Variables sensibles

`cloudflare_api_token`, `cloudflare_account_id` y `cloudflare_zone_id` **no** están en los `.tfvars` (esos se suben al repo). Se pasan como variables de entorno:

```bash
export TF_VAR_cloudflare_api_token="..."
export TF_VAR_cloudflare_account_id="..."
export TF_VAR_cloudflare_zone_id="..."
```

En el pipeline de GitHub Actions, estas mismas variables se leen desde GitHub Secrets (ver diagrama de seguridad).
