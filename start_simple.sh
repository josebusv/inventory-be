#!/bin/bash
# Script simplificado para diagnosticar Cloud Run

echo "🚀 Iniciando aplicación en Cloud Run..."

# Configurar variables de entorno para Cloud SQL
if [ ! -z "$INSTANCE_CONNECTION_NAME" ]; then
    echo "� Configurando conexión a Cloud SQL..."
    export POSTGRES_HOST="/cloudsql/$INSTANCE_CONNECTION_NAME"
fi

echo "�🔍 Variables de entorno:"
echo "  - PORT: $PORT"
echo "  - POSTGRES_HOST: $POSTGRES_HOST"
echo "  - POSTGRES_USER: $POSTGRES_USER"
echo "  - POSTGRES_DB: $POSTGRES_DB"
echo "  - INSTANCE_CONNECTION_NAME: $INSTANCE_CONNECTION_NAME"

# Iniciar FastAPI directamente sin migraciones primero
echo "🌟 Iniciando servidor FastAPI..."
exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080} --workers 1