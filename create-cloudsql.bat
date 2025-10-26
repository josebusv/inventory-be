@echo off
REM Script para crear instancia de Cloud SQL
echo Creando instancia de Cloud SQL PostgreSQL...
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

set /p INSTANCE_NAME=🗄️  Nombre de la instancia Cloud SQL (ej. inventory-db): 
set /p DB_PASSWORD=🔐 Contraseña para el usuario postgres: 

echo.
echo 📋 Creando instancia Cloud SQL:
echo   - Proyecto: %PROJECT_ID%
echo   - Región: %REGION%
echo   - Instancia: %INSTANCE_NAME%
echo.

REM Crear instancia Cloud SQL
echo 🚀 Creando instancia PostgreSQL...
gcloud sql instances create %INSTANCE_NAME% ^
    --database-version=POSTGRES_15 ^
    --tier=db-f1-micro ^
    --region=%REGION% ^
    --root-password=%DB_PASSWORD% ^
    --storage-type=SSD ^
    --storage-size=10GB

REM Crear base de datos
echo 📊 Creando base de datos inventory_db...
gcloud sql databases create inventory_db --instance=%INSTANCE_NAME%

REM Crear usuario de aplicación
set /p APP_USER=👤 Nombre de usuario para la aplicación (ej. inventory_user): 
set /p APP_PASSWORD=🔑 Contraseña para el usuario de aplicación: 

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

echo.
echo ✅ Instancia Cloud SQL creada exitosamente!
echo 📄 Connection Name: %CONNECTION_NAME%
echo.
echo 📝 Próximo paso:
echo   - Desplegar aplicación: .\deploy-cloudrun.bat
echo.
pause