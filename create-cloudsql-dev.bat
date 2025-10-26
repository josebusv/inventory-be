@echo off
REM Script para crear Cloud SQL en modo DESARROLLO (ECONÓMICO)
echo 🛠️  Creando Cloud SQL en modo DESARROLLO (configuración mínima)...
echo.

REM Leer configuración
if not exist gcp-config.txt (
    echo ❌ Archivo de configuración no encontrado.
    echo Ejecute primero: .\setup-gcp.bat
    pause
    exit /b 1
)

for /f "tokens=2 delims==" %%i in ('findstr "PROJECT_ID" gcp-config.txt') do set PROJECT_ID=%%i
for /f "tokens=2 delims==" %%i in ('findstr "REGION" gcp-config.txt') do set REGION=%%i

set INSTANCE_NAME=inventory-db-dev
set DB_PASSWORD=dev123456

echo 💰 Configuración ECONÓMICA para desarrollo:
echo   - Proyecto: %PROJECT_ID%
echo   - Región: %REGION%
echo   - Instancia: %INSTANCE_NAME%
echo   - Tier: db-f1-micro (GRATIS elegible)
echo   - Storage: 10GB SSD (mínimo)
echo   - Backup: Deshabilitado (para ahorrar)
echo.

echo ⚠️  NOTA: Esta configuración es SOLO para desarrollo
echo    NO usar en producción - sin backups automáticos
echo.

set /p CONFIRM=¿Continuar con configuración de desarrollo? (y/n): 
if not "%CONFIRM%"=="y" (
    echo ❌ Operación cancelada.
    pause
    exit /b 0
)

REM Crear instancia Cloud SQL con configuración mínima
echo 🚀 Creando instancia PostgreSQL (configuración mínima)...
gcloud sql instances create %INSTANCE_NAME% ^
    --database-version=POSTGRES_15 ^
    --tier=db-f1-micro ^
    --region=%REGION% ^
    --root-password=%DB_PASSWORD% ^
    --storage-type=SSD ^
    --storage-size=10GB ^
    --no-backup ^
    --maintenance-release-channel=production ^
    --maintenance-window-day=SUN ^
    --maintenance-window-hour=03 ^
    --no-deletion-protection

if %errorlevel% neq 0 (
    echo ❌ Error creando la instancia Cloud SQL
    pause
    exit /b 1
)

REM Crear base de datos
echo 📊 Creando base de datos inventory_db...
gcloud sql databases create inventory_db --instance=%INSTANCE_NAME%

REM Crear usuario de aplicación con credenciales simples para desarrollo
set APP_USER=dev_user
set APP_PASSWORD=dev123456

echo 👥 Creando usuario de aplicación...
gcloud sql users create %APP_USER% --instance=%INSTANCE_NAME% --password=%APP_PASSWORD%

REM Obtener connection name
for /f "tokens=*" %%i in ('gcloud sql instances describe %INSTANCE_NAME% --format="value(connectionName)"') do set CONNECTION_NAME=%%i

REM Actualizar archivo de configuración
echo INSTANCE_NAME=%INSTANCE_NAME% >> gcp-config.txt
echo CONNECTION_NAME=%CONNECTION_NAME% >> gcp-config.txt
echo DB_PASSWORD=%DB_PASSWORD% >> gcp-config.txt
echo APP_USER=%APP_USER% >> gcp-config.txt
echo APP_PASSWORD=%APP_PASSWORD% >> gcp-config.txt
echo DEV_MODE=true >> gcp-config.txt

echo.
echo ✅ Cloud SQL creado en modo desarrollo!
echo 📄 Connection Name: %CONNECTION_NAME%
echo 💰 Costo estimado: ~$7-12/mes (tier gratuito elegible)
echo.
echo 🔐 Credenciales de desarrollo:
echo   - Usuario DB: %APP_USER%
echo   - Password DB: %APP_PASSWORD%
echo.
echo ⚠️  RECORDATORIO: Cambiar credenciales en producción
echo.
echo 📝 Próximo paso: .\deploy-cloudrun-dev.bat
pause