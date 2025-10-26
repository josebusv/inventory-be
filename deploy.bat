@echo off
echo Iniciando despliegue del contenedor de Inventory API...
echo.

echo 1. Deteniendo contenedores existentes...
docker-compose down

echo.
echo 2. Construyendo la imagen de la aplicacion...
docker-compose build --no-cache

echo.
echo 3. Iniciando los servicios...
docker-compose up -d

echo.
echo 4. Verificando el estado de los contenedores...
docker-compose ps

echo.
echo 5. Mostrando los logs de la aplicacion...
timeout /t 5 /nobreak > nul
docker-compose logs app

echo.
echo ========================================
echo Despliegue completado!
echo La API esta disponible en: http://localhost:8000
echo Documentacion (Swagger): http://localhost:8000/docs
echo ========================================