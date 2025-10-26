# Despliegue Manual en Google Cloud Console (Navegador)

Esta guía te permitirá desplegar la aplicación **Inventory API** en Google Cloud Run usando únicamente la consola web de Google Cloud, sin necesidad de línea de comandos.

## 📋 Prerrequisitos

1. **Cuenta de Google Cloud** con facturación habilitada
2. **Proyecto de Google Cloud** creado
3. **Docker** instalado localmente (para construir la imagen)
4. **Código fuente** del proyecto descargado

## 🚀 Paso a Paso Completo

### Paso 1: Preparar el Proyecto

#### 1.1 Acceder a Google Cloud Console
1. Ve a [console.cloud.google.com](https://console.cloud.google.com)
2. Inicia sesión con tu cuenta de Google
3. Selecciona tu proyecto o crea uno nuevo

#### 1.2 Habilitar APIs necesarias
1. En el menú lateral, ve a **"APIs y servicios" > "Biblioteca"**
2. Busca y habilita las siguientes APIs:
   - **Cloud Run API**
   - **Cloud SQL Admin API**
   - **Container Registry API**
   - **Compute Engine API**

### Paso 2: Crear Instancia de Cloud SQL

#### 2.1 Acceder a Cloud SQL
1. En el menú lateral, ve a **"SQL"**
2. Clic en **"Crear instancia"**

#### 2.2 Configurar la instancia
1. Selecciona **"PostgreSQL"**
2. Configura los siguientes valores:
   - **ID de instancia**: `inventory-db`
   - **Contraseña**: Crea una contraseña segura (guárdala)
   - **Región**: `us-central1`
   - **Zona**: `us-central1-a`

#### 2.3 Configuración de máquina
1. En **"Configuración de máquina"**:
   - **Tipo de máquina**: `db-f1-micro` (económico)
   - **Almacenamiento**: `10 GB SSD`

#### 2.4 Configuración de red
1. En **"Conectividad"**:
   - Marca **"IP pública"**
   - En **"Redes autorizadas"** agrega: `0.0.0.0/0` (temporal para desarrollo)
   - **SSL**: Opcional (desmarca "Requerir SSL")

#### 2.5 Crear la instancia
1. Clic en **"Crear instancia"**
2. Espera 5-10 minutos a que se cree

### Paso 3: Configurar Base de Datos

#### 3.1 Crear base de datos
1. Una vez creada la instancia, clic en su nombre
2. Ve a **"Bases de datos"**
3. Clic en **"Crear base de datos"**
4. Nombre: `inventory_db`
5. Clic en **"Crear"**

#### 3.2 Crear usuario
1. Ve a **"Usuarios"**
2. Clic en **"Agregar cuenta de usuario"**
3. Configura:
   - **Nombre de usuario**: `dev_user`
   - **Contraseña**: Crea una contraseña segura (guárdala)
4. Clic en **"Agregar"**

#### 3.3 Obtener IP pública
1. Ve a **"Descripción general"**
2. Copia la **"Dirección IP pública"** (ej: `34.30.144.164`)

### Paso 4: Preparar Imagen Docker

#### 4.1 Construir imagen localmente
Abre terminal/cmd en tu computadora y ejecuta:

```bash
# Navegar al directorio del proyecto
cd ruta/a/tu/inventory-be

# Construir imagen optimizada
docker build -f Dockerfile.tcp -t inventory-api:cloud .
```

#### 4.2 Etiquetar para Container Registry
```bash
# Reemplaza YOUR_PROJECT_ID con tu ID de proyecto
docker tag inventory-api:cloud gcr.io/YOUR_PROJECT_ID/inventory-api:latest
```

### Paso 5: Subir Imagen a Container Registry

#### 5.1 Configurar autenticación
```bash
# Autenticar Docker con Google Cloud
gcloud auth configure-docker
```

#### 5.2 Subir imagen
```bash
docker push gcr.io/YOUR_PROJECT_ID/inventory-api:latest
```

**Alternativa sin línea de comandos:**
Si no puedes usar comandos, sigue estos pasos:
1. Ve a **"Container Registry"** en la consola
2. Usa **Cloud Build** para construir desde el código fuente (ver paso alternativo al final)

### Paso 6: Ejecutar Migraciones

#### 6.1 Construir imagen de migraciones
```bash
docker build -f Dockerfile.migrate -t inventory-migrate .
```

#### 6.2 Ejecutar migraciones
Edita el archivo `run_migrations.py` con tus datos:
```python
POSTGRES_USER = "dev_user"
POSTGRES_PASSWORD = "TU_PASSWORD_AQUI"
POSTGRES_HOST = "TU_IP_PUBLICA_AQUI"  # Ej: "34.30.144.164"
POSTGRES_PORT = "5432"
POSTGRES_DB = "inventory_db"
```

Luego ejecuta:
```bash
docker run --rm inventory-migrate
```

### Paso 7: Desplegar en Cloud Run

#### 7.1 Acceder a Cloud Run
1. En el menú lateral, ve a **"Cloud Run"**
2. Clic en **"Crear servicio"**

#### 7.2 Configurar el servicio
1. **Nombre del servicio**: `inventory-api`
2. **Región**: `us-central1`
3. **URL de imagen del contenedor**: `gcr.io/YOUR_PROJECT_ID/inventory-api:latest`

#### 7.3 Configurar variables de entorno
En **"Variables y secretos"**, agrega:
```
POSTGRES_USER = dev_user
POSTGRES_PASSWORD = TU_PASSWORD_AQUI
POSTGRES_HOST = TU_IP_PUBLICA_AQUI
POSTGRES_PORT = 5432
POSTGRES_DB = inventory_db
SECRET_KEY = tu_clave_jwt_super_secreta
```

#### 7.4 Configurar recursos
En **"Capacidad"**:
- **CPU**: `1`
- **Memoria**: `512 MiB`
- **Tiempo de espera de solicitud**: `300 segundos`

#### 7.5 Configurar escalabilidad
En **"Escalabilidad automática"**:
- **Número mínimo de instancias**: `0`
- **Número máximo de instancias**: `10`

#### 7.6 Configurar conectividad
En **"Conectividad"**:
- Marca **"Permitir tráfico no autenticado"**

#### 7.7 Desplegar
1. Clic en **"Crear"**
2. Espera 2-3 minutos

### Paso 8: Verificar el Despliegue

#### 8.1 Obtener URL del servicio
1. Una vez desplegado, verás la URL del servicio
2. Ejemplo: `https://inventory-api-xxxxx.us-central1.run.app`

#### 8.2 Probar endpoints
1. **API Base**: `https://TU-URL/`
2. **Documentación**: `https://TU-URL/docs`
3. **Login admin**: 
   ```
   POST https://TU-URL/auth/login?email=admin@example.com&password=admin123
   ```

## 🔧 Método Alternativo: Cloud Build (Sin Docker local)

Si no puedes usar Docker localmente, puedes usar Cloud Build:

### Paso A: Configurar Cloud Build

#### A.1 Habilitar Cloud Build API
1. Ve a **"APIs y servicios" > "Biblioteca"**
2. Busca **"Cloud Build API"** y habilítala

#### A.2 Crear archivo cloudbuild.yaml
Crea un archivo `cloudbuild.yaml` en tu proyecto:

```yaml
steps:
  # Construir imagen
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-f', 'Dockerfile.tcp', '-t', 'gcr.io/$PROJECT_ID/inventory-api:latest', '.']
  
  # Subir imagen
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/inventory-api:latest']

images:
  - 'gcr.io/$PROJECT_ID/inventory-api:latest'
```

#### A.3 Ejecutar build
1. Ve a **"Cloud Build" > "Triggers"**
2. Clic en **"Crear activador"**
3. Conecta tu repositorio de GitHub
4. Configura para usar `cloudbuild.yaml`
5. Ejecuta el build

## 🎯 Resumen de URLs y Credenciales

Una vez completado, tendrás:

### **URLs importantes:**
- **API**: `https://inventory-api-xxxxx.us-central1.run.app`
- **Documentación**: `https://inventory-api-xxxxx.us-central1.run.app/docs`
- **Cloud SQL Studio**: En la consola de Google Cloud

### **Credenciales por defecto:**
- **Usuario admin**: `admin@example.com`
- **Contraseña admin**: `admin123`

### **Configuración Cloud SQL:**
- **Host**: Tu IP pública de Cloud SQL
- **Puerto**: `5432`
- **Base de datos**: `inventory_db`
- **Usuario**: `dev_user`
- **Contraseña**: La que configuraste

## 💰 Estimación de Costos

- **Cloud Run**: ~$0-5/mes (scale-to-zero)
- **Cloud SQL**: ~$7-12/mes (db-f1-micro)
- **Storage**: ~$1-2/mes
- **Total**: ~$8-19/mes

## 🛠️ Solución de Problemas

### Error: "Container failed to start"
1. Ve a **"Cloud Run" > "Tu servicio" > "Logs"**
2. Revisa los logs de error
3. Verifica las variables de entorno
4. Confirma que la imagen se construyó correctamente

### Error: "Database connection failed"
1. Verifica la IP pública de Cloud SQL
2. Confirma que las redes autorizadas incluyen `0.0.0.0/0`
3. Verifica usuario y contraseña
4. Asegúrate de que SSL no sea requerido

### Error: "No tables found"
1. Ejecuta las migraciones manualmente
2. Verifica que `run_migrations.py` tenga las credenciales correctas
3. Construye y ejecuta la imagen de migraciones

## 🔄 Actualizar la Aplicación

Para actualizar el código:

1. **Reconstruir imagen**:
   ```bash
   docker build -f Dockerfile.tcp -t gcr.io/YOUR_PROJECT_ID/inventory-api:latest .
   docker push gcr.io/YOUR_PROJECT_ID/inventory-api:latest
   ```

2. **Redesplegar en Cloud Run**:
   - Ve a tu servicio en Cloud Run
   - Clic en **"Editar y desplegar nueva revisión"**
   - Confirma la imagen y despliega

---

¡Con esta guía deberías poder desplegar la aplicación completamente usando la interfaz web de Google Cloud! 🚀