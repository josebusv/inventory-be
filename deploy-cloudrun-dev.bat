@echo off
REM Script de despliegue para DESARROLLO (configuración mínima)
echo 🛠️  Desplegando en modo DESARROLLO (configuración económica)...
echo.

REM Verificar archivo de configuración
if not exist gcp-config.txt (
    echo ❌ Archivo de configuración no encontrado.
    echo Ejecute primero: .\setup-gcp.bat
    pause
    exit /b 1
)

REM Leer configuración
for /f "tokens=2 delims==" %%i in ('findstr "PROJECT_ID" gcp-config.txt') do set PROJECT_ID=%%i
for /f "tokens=2 delims==" %%i in ('findstr "REGION" gcp-config.txt') do set REGION=%%i
for /f "tokens=2 delims==" %%i in ('findstr "SERVICE_NAME" gcp-config.txt') do set SERVICE_NAME=%%i-dev
for /f "tokens=2 delims==" %%i in ('findstr "IMAGE_NAME" gcp-config.txt') do set IMAGE_NAME=%%i
for /f "tokens=2 delims==" %%i in ('findstr "CONNECTION_NAME" gcp-config.txt') do set CONNECTION_NAME=%%i
for /f "tokens=2 delims==" %%i in ('findstr "APP_USER" gcp-config.txt') do set APP_USER=%%i
for /f "tokens=2 delims==" %%i in ('findstr "APP_PASSWORD" gcp-config.txt') do set APP_PASSWORD=%%i

echo 💰 Configuración de DESARROLLO:
echo   - Proyecto: %PROJECT_ID%
echo   - Región: %REGION%
echo   - Servicio: %SERVICE_NAME%
echo   - Memoria: 256Mi (mínimo)
echo   - CPU: 0.5 (mínimo)
echo   - Instancias: 0-1 (scale-to-zero)
echo.

REM Generar SECRET_KEY simple para desarrollo
set SECRET_KEY=dev_secret_key_for_development_only_not_secure

echo 🔨 Paso 1: Construyendo imagen Docker optimizada para desarrollo...
docker build -f Dockerfile.dev -t %IMAGE_NAME%:dev .

if %errorlevel% neq 0 (
    echo ❌ Error construyendo la imagen Docker
    pause
    exit /b 1
)

echo 📤 Paso 2: Subiendo imagen a Container Registry...
docker tag %IMAGE_NAME%:dev %IMAGE_NAME%:dev
docker push %IMAGE_NAME%:dev

if %errorlevel% neq 0 (
    echo ❌ Error subiendo la imagen
    pause
    exit /b 1
)

echo ⚙️  Paso 3: Desplegando en Cloud Run (configuración mínima)...
gcloud run deploy %SERVICE_NAME% ^
    --image %IMAGE_NAME%:dev ^
    --platform managed ^
    --region %REGION% ^
    --allow-unauthenticated ^
    --set-env-vars "POSTGRES_USER=%APP_USER%" ^
    --set-env-vars "POSTGRES_PASSWORD=%APP_PASSWORD%" ^
    --set-env-vars "POSTGRES_HOST=/cloudsql/%CONNECTION_NAME%" ^
    --set-env-vars "POSTGRES_PORT=5432" ^
    --set-env-vars "POSTGRES_DB=inventory_db" ^
    --set-env-vars "SECRET_KEY=%SECRET_KEY%" ^
    --set-env-vars "ALGORITHM=HS256" ^
    --set-env-vars "ACCESS_TOKEN_EXPIRE_MINUTES=60" ^
    --set-env-vars "INSTANCE_CONNECTION_NAME=%CONNECTION_NAME%" ^
    --add-cloudsql-instances %CONNECTION_NAME% ^
    --memory 256Mi ^
    --cpu 0.5 ^
    --min-instances 0 ^
    --max-instances 1 ^
    --concurrency 80 ^
    --timeout 300 ^
    --cpu-throttling

if %errorlevel% neq 0 (
    echo ❌ Error desplegando en Cloud Run
    pause
    exit /b 1
)

echo.
echo ✅ ¡Despliegue de DESARROLLO completado!
echo.

REM Obtener URL del servicio
for /f "tokens=*" %%i in ('gcloud run services describe %SERVICE_NAME% --region=%REGION% --format="value(status.url)"') do set SERVICE_URL=%%i

echo 🌐 Tu aplicación de DESARROLLO está disponible en:
echo   %SERVICE_URL%
echo.
echo 📚 Documentación API:
echo   %SERVICE_URL%/docs
echo.
echo 🔐 Credenciales por defecto:
echo   Email: admin@example.com
echo   Password: admin123
echo.

REM Guardar información de despliegue
echo SERVICE_URL=%SERVICE_URL% >> gcp-config.txt
echo SECRET_KEY=%SECRET_KEY% >> gcp-config.txt

echo 💰 COSTOS ESTIMADOS (modo desarrollo):
echo   - Cloud Run: ~$0-2/mes (scale-to-zero)
echo   - Cloud SQL: ~$7-12/mes (db-f1-micro)
echo   - Storage: ~$1/mes
echo   - TOTAL: ~$8-15/mes
echo.
echo ⚠️  IMPORTANTE: Esta es una configuración de DESARROLLO
echo   - Sin backups automáticos
echo   - Credenciales simples
echo   - Recursos mínimos
echo   - NO usar en producción
echo.
echo 📄 Configuración guardada en: gcp-config.txt
pause