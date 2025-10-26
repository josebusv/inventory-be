# 🔧 Dockerfiles Corregidos para Google Cloud Run

## 📋 Problemas Identificados y Solucionados

### ❌ **Problemas en el Dockerfile Original:**

1. **Puerto hardcodeado a 8000** - Cloud Run usa puerto dinámico
2. **Comando wait_for_postgres.py** - No necesario en Cloud Run
3. **Ejecución de migraciones en startup** - Causa problemas de autoescalado
4. **Falta usuario no-root** - Requerimiento de seguridad
5. **Configuración no optimizada** para Cloud Run

### ✅ **Soluciones Implementadas:**

1. **Puerto dinámico**: Usa variable `${PORT:-8080}`
2. **Usuario no-root**: Creado usuario `appuser` (uid: 1000)
3. **Scripts optimizados**: Inicio sin migraciones automáticas
4. **Dependencias corregidas**: `gcc`, `postgresql-client`, `curl`
5. **Health checks**: Para monitoreo en Cloud Run
6. **Logs mejorados**: Variables de entorno visibles en startup

## 🐳 **Dockerfiles Disponibles:**

### 1. **`Dockerfile`** - Versión Principal Corregida
```dockerfile
# Optimizado para desarrollo local y Cloud Run
# Usa script start.sh personalizable
```

**Uso:**
```bash
docker build -t inventory-api .
docker run -p 8080:8080 --env-file .env inventory-api
```

### 2. **`Dockerfile.gcp`** - Específico para Google Cloud Console
```dockerfile
# Versión autocontenida optimizada para Cloud Console
# Incluye health checks y logs detallados
# Script de inicio embebido en la imagen
```

**Uso en Cloud Build:**
```bash
docker build -f Dockerfile.gcp -t gcr.io/YOUR_PROJECT_ID/inventory-api:latest .
```

### 3. **`Dockerfile.cloudrun`** - Versión Avanzada
```dockerfile
# Usa start_cloudrun.sh externo
# Optimizado para proyectos complejos
```

## 🚀 **Instrucciones de Despliegue Corregido**

### Para Google Cloud Console (Recomendado):

#### Paso 1: Construir imagen corregida
```bash
# Usar la versión específica para GCP
docker build -f Dockerfile.gcp -t gcr.io/YOUR_PROJECT_ID/inventory-api:fixed .
```

#### Paso 2: Subir a Container Registry
```bash
docker push gcr.io/YOUR_PROJECT_ID/inventory-api:fixed
```

#### Paso 3: Desplegar en Cloud Run
En Google Cloud Console:
1. Ve a **Cloud Run**
2. **Crear servicio**
3. **Imagen**: `gcr.io/YOUR_PROJECT_ID/inventory-api:fixed`
4. **Variables de entorno**:
   ```
   POSTGRES_USER=dev_user
   POSTGRES_PASSWORD=tu_password
   POSTGRES_HOST=tu_ip_cloud_sql
   POSTGRES_PORT=5432
   POSTGRES_DB=inventory_db
   SECRET_KEY=tu_jwt_secret
   ```

### Variables de Entorno Requeridas:

```bash
# Base de datos (REQUERIDAS)
POSTGRES_USER=dev_user
POSTGRES_PASSWORD=tu_password_segura
POSTGRES_HOST=34.30.144.164  # IP de Cloud SQL
POSTGRES_PORT=5432
POSTGRES_DB=inventory_db

# JWT (REQUERIDA)
SECRET_KEY=tu_clave_jwt_super_secreta

# Opcional para Cloud SQL Socket
INSTANCE_CONNECTION_NAME=proyecto:region:instancia

# Cloud Run asigna automáticamente
PORT=8080
```

## 🔍 **Verificación Post-Despliegue:**

### 1. **Health Check**
```bash
curl https://tu-url-cloud-run.run.app/
```
**Respuesta esperada**: `{"message":"Welcome to the API"}`

### 2. **Verificar Logs**
En Cloud Console:
1. **Cloud Run** > **Tu servicio** > **Logs**
2. Buscar mensajes de inicio:
   ```
   🚀 Iniciando Inventory API...
   Variables de entorno:
     PORT: 8080
     POSTGRES_HOST: 34.30.144.164
   🌟 Iniciando servidor FastAPI...
   ```

### 3. **Probar Endpoints**
```bash
# Documentación
curl https://tu-url.run.app/docs

# Login admin
curl -X POST "https://tu-url.run.app/auth/login?email=admin@example.com&password=admin123"
```

## 🛠️ **Solución de Problemas Comunes:**

### Error: "Container failed to start"
**Solución**: Revisar logs en Cloud Console
- Verificar variables de entorno
- Confirmar que la imagen se construyó correctamente

### Error: "Port binding failed"
**Solución**: 
- Asegúrate de usar `${PORT:-8080}` en lugar de puerto fijo
- Verificar que EXPOSE esté configurado correctamente

### Error: "Database connection failed"
**Solución**:
- Verificar IP de Cloud SQL en `POSTGRES_HOST`
- Confirmar credenciales en `POSTGRES_USER` y `POSTGRES_PASSWORD`
- Verificar que redes autorizadas incluyan Cloud Run

### Error: "Permission denied"
**Solución**:
- Verificar que usuario `appuser` tenga permisos
- Confirmar que scripts tengan `chmod +x`

## 📊 **Comparación de Versiones:**

| Característica | Dockerfile Original | Dockerfile.gcp | Dockerfile.cloudrun |
|---|---|---|---|
| Puerto dinámico | ❌ | ✅ | ✅ |
| Usuario no-root | ❌ | ✅ | ✅ |
| Health check | ❌ | ✅ | ❌ |
| Migraciones automáticas | ❌ (problemático) | ❌ (correcto) | ❌ (correcto) |
| Logs detallados | ❌ | ✅ | ✅ |
| Optimizado para GCP | ❌ | ✅ | ✅ |

## 🎯 **Recomendación Final:**

**Para despliegue desde Google Cloud Console**: Usa `Dockerfile.gcp`

**Comandos finales:**
```bash
# 1. Construir imagen corregida
docker build -f Dockerfile.gcp -t gcr.io/triple-nectar-476212-i4/inventory-api:fixed .

# 2. Subir imagen
docker push gcr.io/triple-nectar-476212-i4/inventory-api:fixed

# 3. Desplegar en Cloud Run con la imagen corregida
```

¡Con estos cambios, tu aplicación debería funcionar perfectamente en Google Cloud Run! 🚀