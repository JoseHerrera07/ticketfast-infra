# Ticketfast — Plataforma de Venta de Entradas

Infraestructura serverless en AWS para la plataforma de venta de entradas Ticketfast, gestionada íntegramente con Terraform (aprovisionamiento) y desplegada mediante un pipeline de CI/CD en GitHub Actions.

Trabajo final del curso de Infraestructura como Código (IaC).

## Estructura del repositorio

```
lambdas/                Código fuente de las funciones serverless (Node.js 20)
  recepcion/              Lambda que recibe la compra vía API Gateway y la encola en SQS
  procesamiento/          Lambda que consume la cola, escribe el ticket en DynamoDB y confirma por SES
modules/                 Infraestructura como Código (Terraform), un módulo por servicio
  database/                Tabla DynamoDB de tickets (clave compuesta, GSI, PITR)
  queue/                   Cola SQS de compras + Dead Letter Queue con redrive policy
  security/                Roles IAM de mínimo privilegio para cada Lambda
  compute/                 Funciones Lambda (recepción y procesamiento) + event source mapping
  auth/                    Cognito User Pool y User Pool Client
  api/                     API Gateway HTTP API con authorizer JWT de Cognito
  notifications/           Verificación SES + tópico SNS de alertas
  networking/              VPC, subred pública, Internet Gateway y Security Group
  monitoring/               EC2 en Auto Scaling Group (Prometheus/Grafana) + alarmas CloudWatch
tests/negocio/            Pruebas de negocio end-to-end (flujo completo de compra)
environments/             Variables por ambiente (dev, staging, prod)
.github/workflows/        Pipeline de CI/CD (GitHub Actions)
main.tf, variables.tf,
outputs.tf, providers.tf  Orquestación raíz de todos los módulos
backend.tf                 Remote state de Terraform (S3 + DynamoDB para locks)
```

## Arquitectura

Flujo de compra: **Cloudflare → API Gateway (JWT/Cognito) → Lambda recepción → SQS + DLQ → Lambda procesamiento → DynamoDB → SES**, con monitoreo vía CloudWatch → EC2 (Prometheus/Grafana) → SNS → administrador.

El diagrama completo de arquitectura (`.drawio`) está disponible en el informe del proyecto.

## Requisitos previos

- Node.js 20+
- Terraform (v1.5+)
- Cuenta de AWS y AWS CLI configurado
- Cuenta de Cloudflare (API token, Account ID y Zone ID)
- Git

## Pruebas

Cada Lambda tiene sus propias pruebas unitarias con Jest:

```
cd lambdas/recepcion && npm install && npm test
cd lambdas/procesamiento && npm install && npm test
```

Las pruebas de negocio validan el flujo completo de compra de extremo a extremo (recepción → cola → procesamiento → DynamoDB), incluyendo el caso de doble venta del mismo asiento:

```
cd tests/negocio && npm install && npm test
```

## Despliegue de infraestructura

Desde la raíz del repositorio:

```
terraform init
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

Existen archivos de variables equivalentes para `staging` y `prod` en `environments/`.

## CI/CD

El pipeline (`.github/workflows/cicd.yml`) se ejecuta en cada push y pull request a `main`, en 4 etapas encadenadas:

1. **Pruebas unitarias** (Jest) para ambas Lambdas, en paralelo.
2. **Pruebas de negocio** end-to-end, solo si las unitarias pasan.
3. **Terraform fmt + validate + plan**, solo si las pruebas pasan.
4. **Terraform apply** — actualmente manual, pendiente de contar con un dominio propio en Cloudflare para automatizarlo por completo.

## Variables sensibles

Las credenciales de AWS y Cloudflare no se guardan en el repositorio: se gestionan mediante **GitHub Secrets** (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, `CLOUDFLARE_ZONE_ID`) y se inyectan como variables de entorno en el pipeline. La llave privada SSH del EC2 de monitoreo se genera automáticamente con Terraform y nunca se versiona (`.gitignore`).

## Licencia

Este proyecto es de código abierto para fines educativos.
