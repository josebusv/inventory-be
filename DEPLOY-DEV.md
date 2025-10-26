# 🛠️ Despliegue Económico - Modo Desarrollo

## 💰 Configuración Ultra-Económica

Esta guía te ayuda a desplegar tu Inventory API en Google Cloud Run con la **configuración más económica posible** para desarrollo.

### 💸 **Costo Estimado: $8-15/mes**

## 🚀 Despliegue Rápido (3 Comandos)

### 1️⃣ Configurar Google Cloud
```bash
.\setup-gcp.bat
```

### 2️⃣ Crear Base de Datos (Modo Económico)
```bash
.\create-cloudsql-dev.bat
```

### 3️⃣ Desplegar Aplicación (Configuración Mínima)
```bash
.\deploy-cloudrun-dev.bat
```

## 🔧 Configuración de Desarrollo

### Cloud SQL (PostgreSQL)
- **Tier**: `db-f1-micro` (elegible para tier gratuito)
- **Storage**: 10GB SSD (mínimo)
- **Backups**: Deshabilitados (para ahorrar)
- **Memoria**: 0.6GB
- **CPU**: Compartida

### Cloud Run
- **Memoria**: 256Mi (mínimo)
- **CPU**: 0.5 (mínimo)
- **Min Instances**: 0 (scale-to-zero completo)
- **Max Instances**: 1
- **Concurrency**: 80
- **Timeout**: 300s

## 💰 Desglose de Costos

| Recurso | Configuración | Costo/mes |
|---------|---------------|-----------|
| Cloud SQL | db-f1-micro + 10GB | $7-12 |
| Cloud Run | 256Mi, scale-to-zero | $0-2 |
| Container Registry | Almacenamiento imagen | $1 |
| **TOTAL** | | **$8-15** |

### 🎯 **Características de Ahorro**

- ✅ **Scale-to-zero**: $0 cuando no hay tráfico
- ✅ **Tier gratuito**: Cloud SQL elegible para créditos
- ✅ **Sin backups**: Reduce costos (solo desarrollo)
- ✅ **CPU throttling**: Reduce costos de CPU
- ✅ **Imagen optimizada**: Builds más rápidos

## ⚠️ **Limitaciones de Desarrollo**

### 🚨 NO Usar en Producción
- ❌ Sin backups automáticos
- ❌ Credenciales simples
- ❌ Sin alta disponibilidad
- ❌ Recursos muy limitados
- ❌ Sin monitoreo avanzado

### 📊 **Rendimiento Esperado**
- **Latencia**: 2-5 segundos (cold start)
- **Concurrencia**: Máximo 80 requests simultáneos
- **Uptime**: 99% (sin SLA garantizado)

## 🔐 **Credenciales de Desarrollo**

### Base de Datos
- **Usuario**: `dev_user`
- **Password**: `dev123456`
- **Base de Datos**: `inventory_db`

### Aplicación
- **Email**: admin@example.com
- **Password**: admin123

### JWT
- **Secret Key**: Generada automáticamente (no segura)

## 🛠️ **Comandos de Gestión**

### Ver Estado
```bash
# Ver servicios
gcloud run services list

# Ver Cloud SQL
gcloud sql instances list

# Ver logs
gcloud run services logs tail SERVICE_NAME-dev --region=REGION
```

### Pausar para Ahorrar (Cloud SQL)
```bash
# Parar instancia (ahorra ~80% del costo)
gcloud sql instances patch inventory-db-dev --activation-policy=NEVER

# Reanudar instancia
gcloud sql instances patch inventory-db-dev --activation-policy=ALWAYS
```

### Actualizar Aplicación
```bash
# Solo reconstruir y redesplegar
.\deploy-cloudrun-dev.bat
```

### Eliminar Todo
```bash
# Script de limpieza
.\cleanup-gcp.bat
```

## 📈 **Escalabilidad**

### Migrar a Producción
Cuando estés listo para producción:

1. **Crear nueva instancia Cloud SQL**:
   ```bash
   .\create-cloudsql.bat
   ```

2. **Desplegar versión producción**:
   ```bash
   .\deploy-cloudrun.bat
   ```

3. **Migrar datos** (si necesario):
   ```bash
   gcloud sql export sql inventory-db-dev gs://bucket/backup.sql
   gcloud sql import sql inventory-db-prod gs://bucket/backup.sql
   ```

## 🎛️ **Optimizaciones Adicionales**

### Para Desarrollo Local + Cloud
```bash
# Solo usar Cloud SQL, app local
docker-compose up db
# Cambiar POSTGRES_HOST=localhost en .env
```

### Programar Pausas Automáticas
```bash
# Cloud Scheduler para parar instancia en noches/fines de semana
gcloud scheduler jobs create http sql-stop \
  --schedule="0 22 * * 1-5" \
  --uri="https://sqladmin.googleapis.com/sql/v1beta4/projects/PROJECT/instances/inventory-db-dev/patch" \
  --http-method=PATCH \
  --headers="Authorization=Bearer $(gcloud auth print-access-token)" \
  --message-body='{"settings":{"activationPolicy":"NEVER"}}'
```

## 🎉 **Resultado Final**

Después del despliegue tendrás:

- 🌐 **API funcionando**: https://SERVICE-NAME-dev-HASH.a.run.app
- 📚 **Documentación**: https://SERVICE-NAME-dev-HASH.a.run.app/docs
- 💰 **Costo mínimo**: $8-15/mes
- ⚡ **Scale-to-zero**: $0 cuando no está en uso
- 🛠️ **Perfecto para desarrollo**: Testing, demos, prototipos

## 💡 **Tips Adicionales**

1. **Usar durante horas laborales**: Máximo ahorro con scale-to-zero
2. **Pausar fines de semana**: `gcloud sql instances patch` para parar DB
3. **Monitorear costos**: Cloud Console > Billing
4. **Límites de gasto**: Configurar alertas en $20/mes

¡Perfecto para desarrollo, testing y demos sin quebrar el presupuesto! 🎯