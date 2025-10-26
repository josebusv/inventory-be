# 🚀 Guía de Despliegue - Inventory API

## Prerrequisitos

Antes de desplegar, asegúrate de tener instalado:
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Docker Compose](https://docs.docker.com/compose/install/) (incluido con Docker Desktop)

## 🐳 Despliegue con Docker Compose (Recomendado)

### Método 1: Script Automático
```bash
# Ejecutar el script de despliegue
./deploy.bat
```

### Método 2: Comandos Manuales
```bash
# 1. Construir las imágenes
docker-compose build

# 2. Iniciar los servicios
docker-compose up -d

# 3. Verificar que todo esté funcionando
docker-compose ps
```

## 📊 Verificación del Despliegue

Después del despliegue, puedes acceder a:

- **API**: http://localhost:8000
- **Documentación (Swagger)**: http://localhost:8000/docs
- **Documentación (ReDoc)**: http://localhost:8000/redoc

## 🔧 Comandos Útiles

### Ver estado y logs
```bash
# Ver estado de contenedores
./status.bat

# Ver logs en tiempo real
docker-compose logs -f app

# Ver logs de la base de datos
docker-compose logs db
```

### Gestión de contenedores
```bash
# Detener servicios
docker-compose stop

# Reiniciar servicios
docker-compose restart

# Eliminar todo (contenedores, volúmenes, etc.)
./cleanup.bat
```

### Acceder al contenedor
```bash
# Acceder al shell del contenedor de la app
docker-compose exec app /bin/bash

# Acceder a PostgreSQL
docker-compose exec db psql -U postgres -d inventory_db
```

## 🔐 Configuración de Seguridad

**⚠️ IMPORTANTE para Producción:**

1. Cambia la `SECRET_KEY` en el archivo `.env`
2. Usa contraseñas seguras para PostgreSQL
3. Configura variables de entorno específicas del entorno

## 🗄️ Base de Datos

La aplicación usa PostgreSQL y las migraciones se ejecutan automáticamente al iniciar.

### Conexión manual a la DB
```bash
docker-compose exec db psql -U postgres -d inventory_db
```

## 🐛 Resolución de Problemas

### Puerto 8000 ya en uso
```bash
# Cambiar el puerto en docker-compose.yml
ports:
  - "8001:8000"  # Cambiar 8000 por otro puerto
```

### Problemas de permisos
```bash
# En Windows, ejecutar PowerShell como administrador
# Verificar que Docker Desktop esté funcionando
```

### Reconstruir desde cero
```bash
# Limpiar todo y reconstruir
./cleanup.bat
./deploy.bat
```

## 📁 Estructura del Proyecto

```
inventory-be/
├── app/                    # Código de la aplicación
├── alembic/               # Migraciones de base de datos
├── docker-compose.yml     # Configuración de servicios
├── Dockerfile            # Imagen de la aplicación
├── .env                  # Variables de entorno
├── deploy.bat           # Script de despliegue
├── cleanup.bat          # Script de limpieza
└── status.bat           # Script de estado
```