@echo off
REM Script para limpiar recursos de Google Cloud
echo ⚠️  CUIDADO: Este script eliminará recursos de Google Cloud
echo.

REM Verificar archivo de configuración
if not exist gcp-config.txt (
    echo ❌ Archivo de configuración no encontrado.
    echo No hay recursos para limpiar.
    pause
    exit /b 1
)

REM Leer configuración
for /f "tokens=2 delims==" %%i in ('findstr "PROJECT_ID" gcp-config.txt') do set PROJECT_ID=%%i
for /f "tokens=2 delims==" %%i in ('findstr "REGION" gcp-config.txt') do set REGION=%%i
for /f "tokens=2 delims==" %%i in ('findstr "SERVICE_NAME" gcp-config.txt') do set SERVICE_NAME=%%i
for /f "tokens=2 delims==" %%i in ('findstr "INSTANCE_NAME" gcp-config.txt') do set INSTANCE_NAME=%%i

echo 📋 Recursos a eliminar:
echo   - Cloud Run Service: %SERVICE_NAME%
echo   - Cloud SQL Instance: %INSTANCE_NAME%
echo   - Container Images en %PROJECT_ID%
echo.

set /p CONFIRM=¿Está seguro de que desea eliminar TODOS estos recursos? (yes/no): 
if not "%CONFIRM%"=="yes" (
    echo ❌ Operación cancelada.
    pause
    exit /b 0
)

echo.
echo 🗑️  Eliminando recursos...

REM Eliminar servicio de Cloud Run
if not "%SERVICE_NAME%"=="" (
    echo 🚀 Eliminando Cloud Run service...
    gcloud run services delete %SERVICE_NAME% --region=%REGION% --quiet
)

REM Eliminar instancia de Cloud SQL
if not "%INSTANCE_NAME%"=="" (
    echo 🗄️  Eliminando Cloud SQL instance...
    gcloud sql instances delete %INSTANCE_NAME% --quiet
)

REM Eliminar imágenes de container
echo 🐳 Listando imágenes de container...
gcloud container images list --repository=gcr.io/%PROJECT_ID%

echo.
set /p DELETE_IMAGES=¿Desea eliminar las imágenes de container? (yes/no): 
if "%DELETE_IMAGES%"=="yes" (
    echo 🗑️  Eliminando imágenes...
    for /f %%i in ('gcloud container images list --repository=gcr.io/%PROJECT_ID% --format="value(name)"') do (
        gcloud container images delete %%i --force-delete-tags --quiet
    )
)

echo.
echo ✅ Limpieza completada!
echo 📄 Archivo de configuración: gcp-config.txt conservado para referencia
echo.
pause