#!/bin/bash
# Script de inicio para Google Cloud Run

set -e

echo "🚀 Iniciando aplicación en Cloud Run..."

# Configurar variables de entorno para Cloud SQL
if [ ! -z "$INSTANCE_CONNECTION_NAME" ]; then
    echo "📡 Configurando conexión a Cloud SQL..."
    export POSTGRES_HOST="/cloudsql/$INSTANCE_CONNECTION_NAME"
fi

echo "🔍 Variables de entorno configuradas:"
echo "  - POSTGRES_HOST: $POSTGRES_HOST"
echo "  - POSTGRES_DB: $POSTGRES_DB"
echo "  - PORT: $PORT"

# Esperar a que la base de datos esté disponible (solo para development/testing)
if [ "$POSTGRES_HOST" != "/cloudsql/"* ]; then
    echo "⏳ Esperando conexión a base de datos..."
    python wait_for_postgres.py
fi

# Ejecutar migraciones de Alembic
echo "🔄 Ejecutando migraciones..."
alembic upgrade head

# Iniciar el servidor
echo "🌟 Iniciando servidor FastAPI..."
exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080} --workers 1