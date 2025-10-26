# 🚀 Guía de Despliegue en Google Cloud Run

## 📋 Prerrequisitos

### 1. Instalar Google Cloud CLI
- Descarga e instala desde: https://cloud.google.com/sdk/docs/install
- Autentica tu cuenta: `gcloud auth login`

### 2. Herramientas Necesarias
- ✅ Docker Desktop
- ✅ Google Cloud CLI (gcloud)
- ✅ Cuenta de Google Cloud con facturación habilitada

## 🎯 Despliegue Automático (Recomendado)

### Paso 1: Configuración Inicial
```bash
.\setup-gcp.bat
```
Este script:
- ✅ Configura tu proyecto de Google Cloud
- ✅ Habilita las APIs necesarias (Cloud Run, Cloud SQL, Cloud Build)
- ✅ Configura autenticación Docker
- ✅ Crea archivo de configuración `gcp-config.txt`

### Paso 2: Crear Base de Datos Cloud SQL
```bash
.\create-cloudsql.bat
```
Este script:
- ✅ Crea instancia PostgreSQL en Cloud SQL
- ✅ Configura base de datos `inventory_db`
- ✅ Crea usuario de aplicación
- ✅ Guarda connection string

### Paso 3: Desplegar Aplicación
```bash
.\deploy-cloudrun.bat
```
Este script:
- ✅ Construye imagen Docker optimizada para Cloud Run
- ✅ Sube imagen a Container Registry
- ✅ Despliega servicio en Cloud Run
- ✅ Configura variables de entorno automáticamente
- ✅ Conecta con Cloud SQL

## 🔧 Despliegue Manual

### 1. Configurar Proyecto
```bash
# Configurar proyecto
gcloud config set project TU_PROJECT_ID

# Habilitar APIs
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Configurar Docker
gcloud auth configure-docker
```

### 2. Crear Cloud SQL
```bash
# Crear instancia
gcloud sql instances create inventory-db \
    --database-version=POSTGRES_15 \
    --tier=db-f1-micro \
    --region=us-central1 \
    --root-password=TU_PASSWORD

# Crear base de datos
gcloud sql databases create inventory_db --instance=inventory-db

# Crear usuario
gcloud sql users create inventory_user \
    --instance=inventory-db \
    --password=USER_PASSWORD
```

### 3. Construir y Subir Imagen
```bash
# Construir imagen
docker build -f Dockerfile.cloudrun -t gcr.io/TU_PROJECT_ID/inventory-api .

# Subir a Container Registry
docker push gcr.io/TU_PROJECT_ID/inventory-api
```

### 4. Desplegar en Cloud Run
```bash
gcloud run deploy inventory-api \
    --image gcr.io/TU_PROJECT_ID/inventory-api \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-env-vars "POSTGRES_USER=inventory_user" \
    --set-env-vars "POSTGRES_PASSWORD=USER_PASSWORD" \
    --set-env-vars "POSTGRES_HOST=/cloudsql/TU_PROJECT_ID:us-central1:inventory-db" \
    --set-env-vars "POSTGRES_PORT=5432" \
    --set-env-vars "POSTGRES_DB=inventory_db" \
    --set-env-vars "SECRET_KEY=TU_SECRET_KEY_32_CARACTERES" \
    --add-cloudsql-instances TU_PROJECT_ID:us-central1:inventory-db \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 10
```

## 🔐 Configuración de Seguridad

### Variables de Entorno Críticas

**⚠️ OBLIGATORIO cambiar en producción:**

1. **SECRET_KEY**: Mínimo 32 caracteres aleatorios
2. **POSTGRES_PASSWORD**: Contraseña segura para la base de datos
3. **APP_PASSWORD**: Contraseña del usuario de aplicación

### Configuración de Acceso

- **Autenticación**: Configurada como `--allow-unauthenticated` para API pública
- **Para uso privado**: Remover `--allow-unauthenticated` y configurar IAM

## 🗄️ Gestión de Base de Datos

### Conexión Manual a Cloud SQL
```bash
# Instalar Cloud SQL Proxy
gcloud sql connect inventory-db --user=postgres
```

### Backup de Base de Datos
```bash
# Crear backup
gcloud sql backups create --instance=inventory-db

# Restaurar backup
gcloud sql backups restore BACKUP_ID --restore-instance=inventory-db
```

## 📊 Monitoreo y Logs

### Ver Logs de Cloud Run
```bash
# Logs en tiempo real
gcloud run services logs tail inventory-api --region=us-central1

# Logs históricos
gcloud run services logs read inventory-api --region=us-central1
```

### Métricas en Cloud Console
- Accede a: https://console.cloud.google.com/run
- Selecciona tu servicio para ver métricas

## 💰 Optimización de Costos

### Configuración Recomendada para Producción

**Tier básico (Desarrollo/Testing):**
- Cloud SQL: `db-f1-micro` (1 vCPU, 0.6GB RAM)
- Cloud Run: 512Mi RAM, 1 CPU
- Costo estimado: ~$15-30/mes

**Tier medio (Producción pequeña):**
- Cloud SQL: `db-g1-small` (1 vCPU, 1.7GB RAM)
- Cloud Run: 1Gi RAM, 1 CPU
- Costo estimado: ~$50-80/mes

### Tips de Ahorro
- ✅ Configurar `min-instances=0` para scale-to-zero
- ✅ Usar `--cpu-throttling` para cargas variables
- ✅ Programar paradas de Cloud SQL en horarios no laborales

## 🔄 Actualizaciones

### Actualizar la Aplicación
```bash
# Opción 1: Usar script automático
.\deploy-cloudrun.bat

# Opción 2: Manual
docker build -f Dockerfile.cloudrun -t gcr.io/TU_PROJECT_ID/inventory-api .
docker push gcr.io/TU_PROJECT_ID/inventory-api
gcloud run deploy inventory-api --image gcr.io/TU_PROJECT_ID/inventory-api --region us-central1
```

## 🐛 Resolución de Problemas

### Error de Conexión a Cloud SQL
```bash
# Verificar instancia
gcloud sql instances describe inventory-db

# Verificar connection name
gcloud sql instances describe inventory-db --format="value(connectionName)"
```

### Error de Permisos
```bash
# Verificar permisos del proyecto
gcloud projects get-iam-policy TU_PROJECT_ID

# Agregar rol necesario
gcloud projects add-iam-policy-binding TU_PROJECT_ID \
    --member="user:tu-email@gmail.com" \
    --role="roles/run.admin"
```

### Error de Build
```bash
# Limpiar cache local
docker system prune -a

# Reconstruir imagen
docker build --no-cache -f Dockerfile.cloudrun -t gcr.io/TU_PROJECT_ID/inventory-api .
```

## 📁 Archivos del Proyecto

```
inventory-be/
├── Dockerfile.cloudrun          # Dockerfile optimizado para Cloud Run
├── start_cloudrun.sh           # Script de inicio para Cloud Run
├── .env.cloudrun              # Variables de entorno de ejemplo
├── app/core/config_cloudrun.py # Configuración para Cloud SQL
├── setup-gcp.bat              # Script de configuración inicial
├── create-cloudsql.bat        # Script para crear Cloud SQL
├── deploy-cloudrun.bat        # Script de despliegue
└── gcp-config.txt             # Configuración generada (creado automáticamente)
```

## 🌐 Acceso Final

Después del despliegue exitoso:

- **URL de la API**: https://inventory-api-HASH-uc.a.run.app
- **Documentación**: https://inventory-api-HASH-uc.a.run.app/docs
- **Credenciales por defecto**:
  - Email: admin@example.com
  - Password: admin123

## 🎉 ¡Listo!

Tu aplicación Inventory API ahora está funcionando en Google Cloud Run con:
- ✅ Escalado automático
- ✅ HTTPS automático
- ✅ Base de datos PostgreSQL administrada
- ✅ Backups automáticos
- ✅ Monitoreo integrado