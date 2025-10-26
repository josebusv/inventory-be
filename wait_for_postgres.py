#!/usr/bin/env python
import time
import psycopg2
import os
import sys

def wait_for_postgres():
    """Espera a que PostgreSQL esté disponible"""
    max_retries = 30
    retry_interval = 2
    
    for attempt in range(max_retries):
        try:
            conn = psycopg2.connect(
                host=os.getenv('POSTGRES_HOST', 'db'),
                database=os.getenv('POSTGRES_DB', 'inventory_db'),
                user=os.getenv('POSTGRES_USER', 'postgres'),
                password=os.getenv('POSTGRES_PASSWORD', 'postgres123'),
                port=os.getenv('POSTGRES_PORT', '5432')
            )
            conn.close()
            print("✅ PostgreSQL está listo!")
            return True
        except psycopg2.OperationalError:
            print(f"⏳ Esperando a PostgreSQL... intento {attempt + 1}/{max_retries}")
            time.sleep(retry_interval)
    
    print("❌ No se pudo conectar a PostgreSQL después de todos los intentos")
    return False

if __name__ == "__main__":
    if not wait_for_postgres():
        sys.exit(1)