# Inventory Management API

Una API REST moderna para gestión de inventarios construida con **FastAPI**, **PostgreSQL** y **SQLAlchemy**. Incluye autenticación JWT, migraciones automáticas con Alembic y está preparada para despliegue en Google Cloud Run.

## 🚀 Características

- ✅ **API REST completa** con FastAPI
- ✅ **Autenticación JWT** segura
- ✅ **Base de datos PostgreSQL** con SQLAlchemy ORM
- ✅ **Migraciones automáticas** con Alembic
- ✅ **Documentación automática** con Swagger UI
- ✅ **Containerización** con Docker
- ✅ **Datos de ejemplo** incluidos
- ✅ **Despliegue en Cloud Run** configurado

## 📋 Requisitos

- **Docker** y **Docker Compose**
- **Python 3.13+** (para desarrollo local)
- **PostgreSQL** (incluido en Docker Compose)

## ⚙️ Configuración

### 1. Clonar el repositorio

```bash
git clone https://github.com/josebusv/inventory-be.git
cd inventory-be
```

### 2. Configurar variables de entorno

```bash
# Copiar el archivo de ejemplo
cp .env.example .env

# Editar las variables según tu entorno
nano .env  # o usar tu editor preferido
```

### 3. Variables de entorno requeridas

El archivo `.env` debe contener:

```env
# Base de datos
POSTGRES_USER=postgres
POSTGRES_PASSWORD=tu_password_aqui
POSTGRES_HOST=db  # Para Docker Compose
POSTGRES_PORT=5432
POSTGRES_DB=inventory_db

# JWT
SECRET_KEY=tu_clave_secreta_super_segura
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60

# App
APP_NAME=Inventory API
VERSION=2.0.0
PORT=8000
```

## 🐳 Desarrollo Local con Docker

### Opción 1: Docker Compose (Recomendado)

```bash
# Construir y levantar todos los servicios
docker-compose up --build

# En modo detached (segundo plano)
docker-compose up -d --build

# Ver logs
docker-compose logs -f

# Parar servicios
docker-compose down
```

### Opción 2: Docker directo

```bash
# Construir la imagen
docker build -t inventory-api .

# Ejecutar con base de datos externa
docker run -p 8000:8000 --env-file .env inventory-api
```

## 💻 Desarrollo Local sin Docker

### 1. Instalar dependencias

```bash
# Crear entorno virtual
python -m venv venv

# Activar entorno virtual
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt
```

### 2. Configurar base de datos

```bash
# Asegúrate de tener PostgreSQL ejecutándose
# Actualiza POSTGRES_HOST=localhost en tu .env

# Ejecutar migraciones
alembic upgrade head
```

### 3. Ejecutar la aplicación

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 📊 Acceso a la Aplicación

Una vez ejecutándose, la API estará disponible en:

- **API Base**: http://localhost:8000
- **Documentación Swagger**: http://localhost:8000/docs
- **Documentación ReDoc**: http://localhost:8000/redoc

## 🔐 Usuario Administrador por Defecto

Al iniciar la aplicación por primera vez, se crea automáticamente un usuario administrador:

- **Email**: `admin@example.com`
- **Contraseña**: `admin123`
- **Nombre**: `Admin User`

### Ejemplo de Login

```bash
curl -X POST "http://localhost:8000/auth/login?email=admin@example.com&password=admin123"
```

## 🗄️ Estructura de la Base de Datos

La aplicación crea automáticamente las siguientes tablas:

- **users** - Usuarios del sistema
- **profiles** - Perfiles de usuario (extensión de users)
- **products** - Catálogo de productos
- **transactions** - Transacciones de inventario
- **alembic_version** - Control de migraciones

## 📝 Endpoints Principales

### Autenticación
- `POST /auth/register` - Registrar nuevo usuario
- `POST /auth/login` - Iniciar sesión

### Usuarios
- `GET /users/me` - Obtener perfil actual
- `PUT /users/me` - Actualizar perfil
- `GET /users/` - Listar usuarios (admin)

### Productos
- `GET /products/` - Listar productos
- `POST /products/` - Crear producto
- `GET /products/{id}` - Obtener producto
- `PUT /products/{id}` - Actualizar producto
- `DELETE /products/{id}` - Eliminar producto

### Transacciones
- `GET /transactions/` - Listar transacciones
- `POST /transactions/` - Crear transacción
- `GET /transactions/{id}` - Obtener transacción

### Dashboard
- `GET /dashboard/stats` - Estadísticas del inventario

## 🔧 Migraciones de Base de Datos

### Crear nueva migración

```bash
alembic revision --autogenerate -m "Descripción del cambio"
```

### Aplicar migraciones

```bash
alembic upgrade head
```

### Ver historial de migraciones

```bash
alembic history
```

### Revertir migración

```bash
alembic downgrade -1
```

## ☁️ Despliegue en Google Cloud Run

> 📖 **Guías de despliegue disponibles:**
> - **Línea de comandos**: Sigue esta sección
> - **Interfaz web**: Ver [MANUAL_DEPLOYMENT.md](MANUAL_DEPLOYMENT.md) para despliegue paso a paso desde la consola web

### Prerrequisitos

1. **Google Cloud CLI** instalado y configurado
2. **Proyecto de Google Cloud** creado
3. **Billing** habilitado en el proyecto

### 1. Configurar Google Cloud

```bash
# Autenticar
gcloud auth login

# Configurar proyecto
gcloud config set project YOUR_PROJECT_ID

# Habilitar APIs necesarias
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

### 2. Crear instancia de Cloud SQL

```bash
# Crear instancia PostgreSQL
gcloud sql instances create inventory-db \
    --database-version=POSTGRES_17 \
    --tier=db-f1-micro \
    --region=us-central1 \
    --storage-size=10GB \
    --storage-type=SSD

# Crear base de datos
gcloud sql databases create inventory_db --instance=inventory-db

# Crear usuario
gcloud sql users create dev_user \
    --instance=inventory-db \
    --password=YOUR_SECURE_PASSWORD
```

### 3. Configurar conectividad

```bash
# Obtener IP pública de la instancia
gcloud sql instances describe inventory-db --format="value(ipAddresses[0].ipAddress)"

# Autorizar conexiones (para desarrollo)
gcloud sql instances patch inventory-db --authorized-networks=0.0.0.0/0

# Para producción, usar conexiones privadas o VPC
```

### 4. Construir y subir imagen

```bash
# Configurar Docker para GCR
gcloud auth configure-docker

# Construir imagen optimizada
docker build -f Dockerfile.cloudrun -t gcr.io/YOUR_PROJECT_ID/inventory-api:latest .

# Subir imagen
docker push gcr.io/YOUR_PROJECT_ID/inventory-api:latest
```

### 5. Ejecutar migraciones

```bash
# Actualizar run_migrations.py con tus credenciales de Cloud SQL
# Construir imagen de migraciones
docker build -f Dockerfile.migrate -t inventory-migrate .

# Ejecutar migraciones
docker run --rm inventory-migrate
```

### 6. Desplegar en Cloud Run

```bash
gcloud run deploy inventory-api \
    --image gcr.io/YOUR_PROJECT_ID/inventory-api:latest \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated \
    --set-env-vars "POSTGRES_USER=dev_user" \
    --set-env-vars "POSTGRES_PASSWORD=YOUR_SECURE_PASSWORD" \
    --set-env-vars "POSTGRES_HOST=YOUR_CLOUD_SQL_IP" \
    --set-env-vars "POSTGRES_PORT=5432" \
    --set-env-vars "POSTGRES_DB=inventory_db" \
    --set-env-vars "SECRET_KEY=YOUR_JWT_SECRET" \
    --memory 512Mi \
    --cpu 1 \
    --min-instances 0 \
    --max-instances 10
```

## 💰 Costos Estimados (Google Cloud)

- **Cloud Run**: ~$0-5/mes (con scale-to-zero)
- **Cloud SQL db-f1-micro**: ~$7-12/mes
- **Storage y transferencia**: ~$1-3/mes
- **Total estimado**: $8-20/mes

## 🛡️ Seguridad

### Para Producción

1. **Cambiar credenciales por defecto**
2. **Usar secrets management** (Google Secret Manager)
3. **Configurar HTTPS** (automático en Cloud Run)
4. **Restringir redes autorizadas** en Cloud SQL
5. **Habilitar SSL** en conexiones de base de datos
6. **Configurar CORS** apropiadamente
7. **Implementar rate limiting**

### Variables sensibles

Nunca commitear en git:
- Contraseñas de base de datos
- Claves JWT
- Credenciales de servicios cloud

## 🧪 Testing

```bash
# Ejecutar tests (cuando estén implementados)
pytest

# Con cobertura
pytest --cov=app tests/
```

## 📁 Estructura del Proyecto

```
inventory-be/
├── app/
│   ├── core/
│   │   ├── config.py          # Configuración
│   │   ├── database.py        # Conexión DB
│   │   ├── dependencies.py    # Dependencias FastAPI
│   │   ├── init_data.py       # Datos iniciales
│   │   └── security.py        # JWT y passwords
│   ├── models/
│   │   ├── users.py           # Modelo Usuario
│   │   ├── profiles.py        # Modelo Perfil
│   │   ├── products.py        # Modelo Producto
│   │   └── transactions.py    # Modelo Transacción
│   ├── routers/
│   │   ├── auth.py            # Endpoints auth
│   │   ├── users.py           # Endpoints usuarios
│   │   ├── products.py        # Endpoints productos
│   │   ├── transactions.py    # Endpoints transacciones
│   │   └── dashboard.py       # Endpoints dashboard
│   ├── schemas/
│   │   └── *.py               # Schemas Pydantic
│   └── main.py                # App principal
├── alembic/
│   ├── versions/              # Migraciones
│   └── env.py                 # Config Alembic
├── docker-compose.yml         # Desarrollo local
├── Dockerfile                 # Imagen principal
├── Dockerfile.cloudrun        # Imagen optimizada Cloud Run
├── requirements.txt           # Dependencias Python
├── .env.example              # Variables de entorno ejemplo
└── README.md                 # Este archivo
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 📞 Soporte

Si tienes problemas o preguntas:

1. **Revisar la documentación** en `/docs` cuando la aplicación esté ejecutándose
2. **Buscar en issues existentes** en GitHub
3. **Crear un nuevo issue** con detalles del problema

## 🔄 Estado del Proyecto

- ✅ **API Base** - Completado
- ✅ **Autenticación** - Completado  
- ✅ **CRUD Productos** - Completado
- ✅ **CRUD Transacciones** - Completado
- ✅ **Dashboard básico** - Completado
- ✅ **Dockerización** - Completado
- ✅ **Cloud Run deployment** - Completado
- 🔄 **Tests unitarios** - En desarrollo
- 🔄 **CI/CD pipeline** - En desarrollo
- 🔄 **Frontend** - Planeado

---

**Desarrollado con ❤️ usando FastAPI y PostgreSQL**
