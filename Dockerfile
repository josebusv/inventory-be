# Usa una imagen base de Python
FROM python:3.13-slim

# Instalar dependencias del sistema necesarias para Cloud Run
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Establece el directorio de trabajo
WORKDIR /app

# Copia los archivos de requirements.txt e instálalos
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copia el resto del código al contenedor
COPY . .

# Crear usuario no root y hacer scripts ejecutables en una sola capa
RUN chmod +x start.sh && \
    useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app

USER appuser

# Cloud Run asigna dinámicamente el puerto a través de la variable PORT
# Por defecto usa 8080, pero puede cambiar
ENV PORT=8080
EXPOSE 8080

# Comando optimizado para Cloud Run usando script de inicio
# NOTA: Las migraciones deben ejecutarse por separado antes del despliegue
# para evitar condiciones de carrera en entornos con autoescalado
CMD ["./start.sh"]