@echo off
echo Deteniendo y eliminando contenedores...
docker-compose down

echo Eliminando imagenes no utilizadas...
docker image prune -f

echo Eliminando volumenes huerfanos...
docker volume prune -f

echo Limpieza completada!