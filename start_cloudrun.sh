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

# NO esperar conexión para Cloud SQL (usa socket Unix)

echo "🔌 Usando Cloud SQL socket Unix, omitiendo wait_for_postgres"

# NOTA: Las migraciones de la base de datos (Alembic) deben ejecutarse como un
# paso separado en tu proceso de CI/CD antes de desplegar una nueva versión.
# Ejecutarlas aquí puede causar condiciones de carrera en entornos con autoescalado.
#
# Ejemplo en Cloud Build:
#   - name: 'gcr.io/google-appengine/exec-wrapper'
#     args:
#       - '-i', 'gcr.io/$PROJECT_ID/inventory-be-migrations',
#       - '-e', 'INSTANCE_CONNECTION_NAME=${_INSTANCE_CONNECTION_NAME}',
#       - '--', 'alembic', 'upgrade', 'head'

# Iniciar el servidor
echo "🌟 Iniciando servidor FastAPI..."
exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080} --workers 1