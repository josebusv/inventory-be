@echo off
REM Script de configuración inicial para Google Cloud Platform
echo Configurando proyecto en Google Cloud Platform...
echo.

REM Verificar si gcloud está instalado
gcloud version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Google Cloud CLI no está instalado.
    echo Por favor, instale Google Cloud CLI desde: https://cloud.google.com/sdk/docs/install
    pause
    exit /b 1
)

echo ✅ Google Cloud CLI detectado
echo.

REM Solicitar información del proyecto
set /p PROJECT_ID=🏷️  Ingrese el PROJECT_ID de Google Cloud: 
set /p REGION=🌍 Ingrese la región (ej. us-central1): 
set /p SERVICE_NAME=🚀 Ingrese el nombre del servicio Cloud Run (ej. inventory-api): 

echo.
echo 📋 Configuración:
echo   - Proyecto: %PROJECT_ID%
echo   - Región: %REGION%
echo   - Servicio: %SERVICE_NAME%
echo.

REM Configurar el proyecto
echo 🔧 Configurando proyecto de Google Cloud...
gcloud config set project %PROJECT_ID%

REM Habilitar APIs necesarias
echo 🔌 Habilitando APIs necesarias...
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudbuild.googleapis.com

REM Configurar autenticación para Docker
echo 🐳 Configurando autenticación Docker...
gcloud auth configure-docker

REM Crear archivo de configuración
echo # Configuración generada automáticamente para Google Cloud > gcp-config.txt
echo PROJECT_ID=%PROJECT_ID% >> gcp-config.txt
echo REGION=%REGION% >> gcp-config.txt
echo SERVICE_NAME=%SERVICE_NAME% >> gcp-config.txt
echo IMAGE_NAME=gcr.io/%PROJECT_ID%/%SERVICE_NAME% >> gcp-config.txt

echo.
echo ✅ Configuración completada!
echo 📄 Los valores se guardaron en: gcp-config.txt
echo.
echo 📝 Próximos pasos:
echo   1. Crear instancia de Cloud SQL: .\create-cloudsql.bat
echo   2. Desplegar aplicación: .\deploy-cloudrun.bat
echo.
pause