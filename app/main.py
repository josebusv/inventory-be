from fastapi import FastAPI
from app.routers import products, transactions, users, auth, dashboard

from app.core.database import create_tables, init_db
from fastapi.middleware.cors import CORSMiddleware
import asyncio
import logging
from sqlalchemy.exc import OperationalError


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permitir todos los orígenes
    allow_credentials=True,  # Permitir cookies/autenticación
    allow_methods=["*"],  # Permitir todos los métodos HTTP (GET, POST, PUT, DELETE, etc.)
    allow_headers=["*"],  # Permitir todos los encabezados
)

app.include_router(users.router)
app.include_router(auth.router)
app.include_router(transactions.router)
app.include_router(products.router)
app.include_router(dashboard.router)


# 🚀 Función robusta para crear tablas con reintentos
async def setup_database():
    """Configurar base de datos con reintentos y backoff exponencial"""
    max_retries = 5
    base_delay = 1  # segundos
    
    for attempt in range(max_retries):
        try:
            logging.info(f"Intento {attempt + 1}/{max_retries} de conexión a la base de datos...")
            create_tables()
            init_db()
            logging.info("✅ Base de datos configurada correctamente")
            return
        except OperationalError as e:
            if attempt == max_retries - 1:
                logging.error(f"❌ No se pudo conectar a la base de datos después de {max_retries} intentos: {e}")
                # No hacer raise - permitir que la app arranque sin BD
                return
            
            delay = base_delay * (2 ** attempt)  # backoff exponencial
            logging.warning(f"⚠️ Error de conexión (intento {attempt + 1}): {e}")
            logging.info(f"🔄 Reintentando en {delay} segundos...")
            await asyncio.sleep(delay)
        except Exception as e:
            logging.error(f"❌ Error inesperado configurando la base de datos: {e}")
            # No hacer raise - permitir que la app arranque
            return

# 🚀 Crear las tablas al iniciar el backend
@app.on_event("startup")
async def on_startup():
    await setup_database()

@app.get("/")
def root():
    return {"message": "Welcome to the API"}