#!/bin/bash

echo "🚀 Iniciando Inventory API en Cloud Run..."

# Configurar variables de entorno para Cloud SQL
if [ ! -z "$INSTANCE_CONNECTION_NAME" ]; then
    echo "📡 Configurando conexión a Cloud SQL via Unix Socket..."
    export POSTGRES_HOST="/cloudsql/$INSTANCE_CONNECTION_NAME"
else
    echo "📡 Usando conexión TCP directa a PostgreSQL..."
fi

echo "🔍 Configuración actual:"
echo "  - POSTGRES_HOST: ${POSTGRES_HOST:-'localhost'}"
echo "  - POSTGRES_DB: ${POSTGRES_DB:-'inventory_db'}"
echo "  - POSTGRES_USER: ${POSTGRES_USER:-'postgres'}"
echo "  - PORT: ${PORT:-8080}"
echo "  - Modo: ${ENVIRONMENT:-'production'}"

# Verificar variables críticas
if [ -z "$POSTGRES_HOST" ] || [ -z "$POSTGRES_DB" ] || [ -z "$POSTGRES_USER" ]; then
    echo "❌ Error: Variables de base de datos requeridas no están configuradas"
    echo "   Requeridas: POSTGRES_HOST, POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD"
    exit 1
fi

# Configurar para Cloud Run
export PYTHONPATH="/app:$PYTHONPATH"

echo "🌟 Iniciando servidor FastAPI..."
echo "   - Host: 0.0.0.0"
echo "   - Puerto: ${PORT:-8080}" 
echo "   - Workers: 1 (optimizado para Cloud Run)"

# Iniciar el servidor con configuración optimizada para Cloud Run
exec uvicorn app.main:app \
    --host 0.0.0.0 \
    --port ${PORT:-8080} \
    --workers 1 \
    --timeout-keep-alive 60 \
    --access-log \
    --log-level info