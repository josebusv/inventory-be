from pydantic_settings import BaseSettings
from dotenv import load_dotenv
import os

load_dotenv()


class Settings(BaseSettings):
    # Configuración general
    APP_NAME: str = "Inventory API"
    VERSION: str = "2.0.0"
    
    # Configuración JWT
    SECRET_KEY: str = os.getenv("SECRET_KEY", "default_secret_key")
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 60))

    # Configuración de Base de Datos
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "postgres")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "postgres")
    POSTGRES_HOST: str = os.getenv("POSTGRES_HOST", "localhost")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "postgres")
    
    # Para Cloud SQL - Connection Name
    INSTANCE_CONNECTION_NAME: str = os.getenv("INSTANCE_CONNECTION_NAME", "")
    
    # URL de base de datos con soporte para Cloud SQL
    @property
    def DATABASE_URL(self) -> str:
        # Si estamos en Cloud Run con Cloud SQL, usar socket Unix
        if self.INSTANCE_CONNECTION_NAME and "/cloudsql/" in self.POSTGRES_HOST:
            return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@/{self.POSTGRES_DB}?host={self.POSTGRES_HOST}"
        else:
            # Conexión tradicional TCP
            return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"

    # Puerto dinámico para Cloud Run
    PORT: int = int(os.getenv("PORT", "8000"))

    class Config:
        env_file = ".env"  # Archivo de variables de entorno

# Instancia global de configuración
settings = Settings()