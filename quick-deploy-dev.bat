@echo off
REM Script de INICIO RÁPIDO para despliegue de desarrollo económico
echo 🚀 DESPLIEGUE RÁPIDO - Modo Desarrollo Económico
echo.
echo 💰 Configuración ultra-económica: $8-15/mes
echo ⚡ Scale-to-zero completo cuando no está en uso
echo 🛠️  Solo para desarrollo (NO producción)
echo.

REM Verificar prerrequisitos
echo ✅ Verificando prerrequisitos...

REM Verificar Google Cloud CLI
gcloud version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Google Cloud CLI no encontrado
    echo 📥 Descargar desde: https://cloud.google.com/sdk/docs/install
    pause
    exit /b 1
)

REM Verificar Docker
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Docker no encontrado
    echo 📥 Instalar Docker Desktop desde: https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

echo ✅ Prerrequisitos verificados!
echo.

REM Mostrar proceso
echo 📋 PROCESO DE DESPLIEGUE (3 pasos):
echo   1️⃣  Configurar Google Cloud Project
echo   2️⃣  Crear Cloud SQL (db-f1-micro)
echo   3️⃣  Desplegar Cloud Run (256Mi RAM)
echo.

set /p CONTINUE=¿Continuar con el despliegue automático? (y/n): 
if not "%CONTINUE%"=="y" (
    echo ❌ Despliegue cancelado
    pause
    exit /b 0
)

echo.
echo 🎯 INICIANDO DESPLIEGUE AUTOMÁTICO...
echo ============================================
echo.

REM Paso 1: Setup GCP
echo 1️⃣  CONFIGURANDO GOOGLE CLOUD...
call setup-gcp.bat
if %errorlevel% neq 0 (
    echo ❌ Error en configuración de Google Cloud
    pause
    exit /b 1
)

echo.
echo ============================================
echo.

REM Paso 2: Crear Cloud SQL
echo 2️⃣  CREANDO BASE DE DATOS (modo económico)...
call create-cloudsql-dev.bat
if %errorlevel% neq 0 (
    echo ❌ Error creando Cloud SQL
    pause
    exit /b 1
)

echo.
echo ============================================
echo.

REM Paso 3: Deploy Cloud Run
echo 3️⃣  DESPLEGANDO APLICACIÓN...
call deploy-cloudrun-dev.bat
if %errorlevel% neq 0 (
    echo ❌ Error desplegando aplicación
    pause
    exit /b 1
)

echo.
echo ============================================
echo ✅ ¡DESPLIEGUE COMPLETADO!
echo ============================================
echo.

REM Leer URL final
if exist gcp-config.txt (
    for /f "tokens=2 delims==" %%i in ('findstr "SERVICE_URL" gcp-config.txt') do set SERVICE_URL=%%i
    
    echo 🎉 Tu Inventory API está funcionando!
    echo.
    echo 🌐 URL Principal: %SERVICE_URL%
    echo 📚 Documentación: %SERVICE_URL%/docs
    echo 🔧 ReDoc: %SERVICE_URL%/redoc
    echo.
    echo 🔐 Credenciales por defecto:
    echo   📧 Email: admin@example.com
    echo   🔑 Password: admin123
    echo.
    echo 💰 COSTOS ESTIMADOS:
    echo   💰 Costo mensual: $8-15/mes
    echo   ⚡ $0 cuando no está en uso (scale-to-zero)
    echo   🎯 Perfecto para desarrollo y testing
    echo.
    echo ⚠️  RECORDATORIO: Esta es configuración de DESARROLLO
    echo   ❌ Sin backups automáticos
    echo   ❌ Credenciales simples
    echo   ❌ NO usar en producción
    echo.
    echo 📄 Configuración guardada en: gcp-config.txt
    echo 📖 Ver guía completa: DEPLOY-DEV.md
)

echo.
echo 🎯 PRÓXIMOS PASOS RECOMENDADOS:
echo   1. Probar API en: %SERVICE_URL%/docs
echo   2. Cambiar credenciales por defecto
echo   3. Configurar alertas de costo en Google Cloud Console
echo   4. Leer DEPLOY-DEV.md para optimizaciones adicionales
echo.

pause