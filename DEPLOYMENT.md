# Instrucciones de Despliegue - Google Cloud Run

Este documento contiene las instrucciones específicas para desplegar esta aplicación en Google Cloud Run, basadas en nuestro despliegue exitoso.

## 🚀 Despliegue Exitoso Completado

**URL de la API**: `https://inventory-api-test-140690429577.us-central1.run.app`

## 📋 Configuración Actual

### Instancia Cloud SQL
- **Nombre**: `josebustospruebas`
- **Proyecto**: `triple-nectar-476212-i4`
- **Región**: `us-central1`
- **Versión**: PostgreSQL 17
- **Tier**: `db-custom-1-3840` (1 vCPU, 3.75GB RAM)
- **Storage**: 10GB SSD
- **IP Pública**: `34.30.144.164`

### Usuario de Base de Datos
- **Usuario**: `dev_user`
- **Contraseña**: `DevPass123!`
- **Base de datos**: `inventory_db`

### Configuración Cloud Run
- **Servicio**: `inventory-api-test`
- **Imagen**: `gcr.io/triple-nectar-476212-i4/inventory-api:tcp`
- **Región**: `us-central1`
- **CPU**: 1
- **Memoria**: 512Mi
- **Min instances**: 0 (scale-to-zero)
- **Max instances**: 1

## 🔧 Comandos Ejecutados

### 1. Configuración inicial de Cloud SQL

```bash
# Habilitar IP pública
gcloud sql instances patch josebustospruebas --assign-ip --project=triple-nectar-476212-i4

# Autorizar todas las conexiones (para desarrollo)
gcloud sql instances patch josebustospruebas --authorized-networks=0.0.0.0/0 --project=triple-nectar-476212-i4

# Desactivar SSL requerido
gcloud sql instances patch josebustospruebas --no-require-ssl --project=triple-nectar-476212-i4
```

### 2. Construcción y subida de imágenes

```bash
# Imagen optimizada para TCP
docker build -f Dockerfile.tcp -t gcr.io/triple-nectar-476212-i4/inventory-api:tcp .
docker push gcr.io/triple-nectar-476212-i4/inventory-api:tcp

# Imagen para migraciones
docker build -f Dockerfile.migrate -t inventory-migrate .
```

### 3. Ejecución de migraciones

```bash
docker run --rm inventory-migrate
```

### 4. Despliegue final en Cloud Run

```bash
gcloud run deploy inventory-api-test \
    --image gcr.io/triple-nectar-476212-i4/inventory-api:tcp \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-env-vars "POSTGRES_USER=dev_user" \
    --set-env-vars "POSTGRES_PASSWORD=DevPass123!" \
    --set-env-vars "POSTGRES_HOST=34.30.144.164" \
    --set-env-vars "POSTGRES_PUBLIC_IP=34.30.144.164" \
    --set-env-vars "POSTGRES_PORT=5432" \
    --set-env-vars "POSTGRES_DB=inventory_db" \
    --set-env-vars "SECRET_KEY=dev_secret_key_tcp" \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 1 \
    --timeout 300
```

## ✅ Verificaciones de Funcionamiento

### 1. API Principal
```bash
curl https://inventory-api-test-140690429577.us-central1.run.app/
```
**Respuesta esperada**: `{"message":"Welcome to the API"}`

### 2. Documentación
```bash
curl https://inventory-api-test-140690429577.us-central1.run.app/docs
```
**Respuesta esperada**: HTML de Swagger UI

### 3. Registro de usuario
```bash
curl -X POST "https://inventory-api-test-140690429577.us-central1.run.app/auth/register" \
     -H "Content-Type: application/json" \
     -d '{"username":"testuser","email":"test@example.com","password":"password123","full_name":"Test User"}'
```
**Respuesta esperada**: JWT token

### 4. Login del usuario admin por defecto
```bash
curl -X POST "https://inventory-api-test-140690429577.us-central1.run.app/auth/login?email=admin@example.com&password=admin123"
```
**Respuesta esperada**: Usuario y JWT token

## 🗄️ Conexión Directa a Cloud SQL

### Usando psql
```bash
psql -h 34.30.144.164 -U dev_user -d inventory_db -p 5432
```

### Usando Docker
```bash
docker run --rm -e PGPASSWORD="DevPass123!" postgres:13 psql -h 34.30.144.164 -U dev_user -d inventory_db -c "\dt"
```

### Usando Cloud SQL Studio
- **Host**: `34.30.144.164`
- **Port**: `5432`
- **Database**: `inventory_db`
- **Username**: `dev_user`
- **Password**: `DevPass123!`
- **SSL Mode**: Disabled/Optional

## 🏗️ Archivos de Configuración Creados

### Dockerfile.tcp
Imagen optimizada para conexión TCP directa a Cloud SQL con IP pública.

### Dockerfile.migrate
Imagen especializada para ejecutar migraciones de Alembic.

### run_migrations.py
Script para ejecutar migraciones estableciendo las variables de entorno correctas.

## 💰 Costos Actuales

### Estimación mensual:
- **Cloud Run**: ~$0-2/mes (scale-to-zero activado)
- **Cloud SQL**: ~$8-12/mes (db-custom-1-3840)
- **Storage y red**: ~$1-2/mes
- **Total**: ~$9-16/mes

## 🔒 Configuración de Seguridad Aplicada

### ✅ Configurado:
- Conexión TCP directa
- Autorización de redes: `0.0.0.0/0` (desarrollo)
- SSL opcional (no requerido)
- Variables de entorno seguras en Cloud Run

### 🔄 Para Producción (recomendado):
```bash
# Restringir redes autorizadas (ejemplo para IPs específicas)
gcloud sql instances patch josebustospruebas --authorized-networks=YOUR_OFFICE_IP/32

# Habilitar SSL requerido
gcloud sql instances patch josebustospruebas --require-ssl

# Usar conexión Unix socket en lugar de TCP
# (requiere configuración VPC Connector)
```

## 🔄 Actualización de la Aplicación

### Para actualizar el código:

1. **Reconstruir imagen**:
```bash
docker build -f Dockerfile.tcp -t gcr.io/triple-nectar-476212-i4/inventory-api:tcp .
docker push gcr.io/triple-nectar-476212-i4/inventory-api:tcp
```

2. **Redesplegar**:
```bash
gcloud run deploy inventory-api-test \
    --image gcr.io/triple-nectar-476212-i4/inventory-api:tcp \
    --region us-central1
```

### Para nuevas migraciones:

1. **Crear migración**:
```bash
alembic revision --autogenerate -m "Descripción del cambio"
```

2. **Ejecutar migración**:
```bash
# Actualizar run_migrations.py si es necesario
docker build -f Dockerfile.migrate -t inventory-migrate .
docker run --rm inventory-migrate
```

## 📊 Monitoreo

### Logs de Cloud Run:
```bash
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=inventory-api-test" --limit=50 --project=triple-nectar-476212-i4
```

### Estado del servicio:
```bash
gcloud run services describe inventory-api-test --region=us-central1 --project=triple-nectar-476212-i4
```

### Operaciones de Cloud SQL:
```bash
gcloud sql operations list --instance=josebustospruebas --project=triple-nectar-476212-i4
```

---

**Despliegue completado exitosamente el 26 de octubre de 2025** 🎉