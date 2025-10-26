@echo off
REM Script principal de despliegue para Google Cloud Run
echo 🚀 Desplegando aplicación en Google Cloud Run...
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
for /f "tokens=2 delims==" %%i in ('findstr "SERVICE_NAME" gcp-config.txt') do set SERVICE_NAME=%%i
for /f "tokens=2 delims==" %%i in ('findstr "IMAGE_NAME" gcp-config.txt') do set IMAGE_NAME=%%i
for /f "tokens=2 delims==" %%i in ('findstr "CONNECTION_NAME" gcp-config.txt') do set CONNECTION_NAME=%%i
for /f "tokens=2 delims==" %%i in ('findstr "APP_USER" gcp-config.txt') do set APP_USER=%%i
for /f "tokens=2 delims==" %%i in ('findstr "APP_PASSWORD" gcp-config.txt') do set APP_PASSWORD=%%i

echo 📋 Configuración de despliegue:
echo   - Proyecto: %PROJECT_ID%
echo   - Región: %REGION%
echo   - Servicio: %SERVICE_NAME%
echo   - Imagen: %IMAGE_NAME%
echo.

REM Generar SECRET_KEY único
for /f %%i in ('powershell -Command "[System.Web.Security.Membership]::GeneratePassword(32,0)"') do set SECRET_KEY=%%i

echo 🔨 Paso 1: Construyendo imagen Docker...
docker build -f Dockerfile.cloudrun -t %IMAGE_NAME% .

echo 📤 Paso 2: Subiendo imagen a Container Registry...
docker push %IMAGE_NAME%

echo ⚙️  Paso 3: Desplegando en Cloud Run...
gcloud run deploy %SERVICE_NAME% ^
    --image %IMAGE_NAME% ^
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
    --memory 512Mi ^
    --cpu 1 ^
    --min-instances 0 ^
    --max-instances 10

echo.
echo ✅ ¡Despliegue completado!
echo.

REM Obtener URL del servicio
for /f "tokens=*" %%i in ('gcloud run services describe %SERVICE_NAME% --region=%REGION% --format="value(status.url)"') do set SERVICE_URL=%%i

echo 🌐 Tu aplicación está disponible en:
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

echo 📄 Toda la configuración se guardó en: gcp-config.txt
echo.
pause