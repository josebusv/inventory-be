@echo off
echo Verificando estado de los contenedores...
docker-compose ps

echo.
echo Logs de la aplicacion (ultimas 50 lineas):
echo ========================================
docker-compose logs --tail=50 app

echo.
echo Logs de la base de datos (ultimas 20 lineas):
echo ========================================
docker-compose logs --tail=20 db