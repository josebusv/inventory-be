#!/usr/bin/env python3
"""
Script para ejecutar migraciones de Alembic en Cloud SQL
"""
import os
import sys
import asyncio
from alembic.config import Config
from alembic import command
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

# Configuración de Cloud SQL
POSTGRES_USER = "dev_user"
POSTGRES_PASSWORD = "DevPass123!"
POSTGRES_HOST = "34.30.144.164"  # IP pública
POSTGRES_PORT = "5432"
POSTGRES_DB = "inventory_db"

# Crear URL de conexión
DATABASE_URL = f"postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}:{POSTGRES_PORT}/{POSTGRES_DB}"

def run_migrations():
    """Ejecutar migraciones de Alembic"""
    print(f"Conectando a: {POSTGRES_HOST}:{POSTGRES_PORT}")
    print(f"Base de datos: {POSTGRES_DB}")
    print(f"Usuario: {POSTGRES_USER}")
    
    # Establecer variables de entorno para que las use settings
    os.environ["POSTGRES_USER"] = POSTGRES_USER
    os.environ["POSTGRES_PASSWORD"] = POSTGRES_PASSWORD
    os.environ["POSTGRES_HOST"] = POSTGRES_HOST
    os.environ["POSTGRES_PORT"] = POSTGRES_PORT
    os.environ["POSTGRES_DB"] = POSTGRES_DB
    
    # Configurar Alembic
    alembic_cfg = Config("alembic.ini")
    alembic_cfg.set_main_option("sqlalchemy.url", DATABASE_URL)
    
    try:
        # Verificar conexión
        engine = create_engine(DATABASE_URL)
        with engine.connect():
            print("✅ Conexión a la base de datos exitosa")
        
        # Ejecutar migraciones
        print("🔄 Ejecutando migraciones...")
        command.upgrade(alembic_cfg, "head")
        print("✅ Migraciones completadas exitosamente")
        
    except Exception as e:
        print(f"❌ Error durante las migraciones: {e}")
        return False
    
    return True

if __name__ == "__main__":
    success = run_migrations()
    sys.exit(0 if success else 1)